comerr  = require "comerr"
_       = require "underscore"
outcome = require "outcome"


###

Server States:

+--------+---------------+
|  Code  |     State     |
+--------+---------------+
|   0    |    pending    | 
|  16    |    running    |
|  32    | shutting-down | 
|  48    |  terminated   |
|  64    |   stopping    | 
|  80    |   stopped     |
+--------+---------------

###


class Instance extends require("../../base/regionModel")

  ###
  ###

  constructor: (data, collection) ->
    super data, collection
    @api = collection.region.api
    @region = collection.region

  ###
  ###

  destroy: (next) ->
    @_runCommand "terminated", _.bind(this.terminate2, this, next), next

  ###
  ###

  terminate2: (next) ->
    @_callAndWaitUntilState "TerminateInstances", "terminated", next

  ###
  ###

  start: (next) ->
    @_runCommand "running", _.bind(@_start2, @, next), next

  ###
  ###

  createImage: (options, next) ->

    if arguments.length is 1
      next    = options
      options = {}

    options = {
      InstanceId: @get("_id"),
      Name: options.name
    }

    o = outcome.e(next)

    @api.call "CreateImage", options, o.s (result) =>

      @region.images.wait { _id: result.imageId }, o.s (images) =>

        next null, images[0]
        ###
        copyTags @, image, { createdAt: Date.now() }, @_o.s () =>
           callback null, image
        ###



  ###
    secondary start function that bypasses the "running" check
  ###

  _start2: (callback) ->

      state = @get "state"

      # stopped? Perfect - this is the state we want to be in
      # TODO: handle the callback result
      if /stopped/.test state
        #@_ec2.call "StartInstances", { "InstanceId.1": @get "_id" }, callback
        @_callAndWaitUntilState "StartInstances", "running", callback
      else

      # server is shutting down
      if /shutting-down|stopping/.test state
        @wait { state: /stopped|terminated/ }, () => @start callback
      else

      # server is still initializing, it'll startup in a bit
      # TODO - pending might throw an error
      if /pending/.test state
        @wait { state: "running" }, callback

  ###
  ###

  stop: (next) ->
    @_runCommand "stopped", _.bind(@_stop2, @, next), next

  ###
  ###

  _stop2: (callback) ->

    state = @get "state"


    if /running/.test state
      # @_ec2.call "StopInstances", { "InstanceId.1": @get "_id" }, callback
      @_callAndWaitUntilState "StopInstances", "stopped", callback
    else
    if /stopping|shutting-down/.test state
      @wait { state: /stopped|terminated/ }, () => @stop callback
    else
    if /pending/.test state
      @wait { state: "running" }, () => @stop callback

  ###
  ###

  restart: (next) -> 
    @stop outcome.e(next).s () => @start next

  ###
    Function: 

    Parameters:
  ###

  _runCommand: (expectedState, runCommand, next) ->

    @skip { state: expectedState }, next, () =>
      state = @get "state"


      if /terminated/.test state
        next new comerr.NotFound "The instance has been terminated."
      else
      if not /stopping|stopped|shutting-down|running|pending/.test state
        next new comerr.UnknownError "An unrecognized instance state was returned."
      else
        runCommand()


  ###
  ###

  _callAndWaitUntilState: (command, state, next) ->

    fn = null

    if typeof command isnt "function"
      fn = (next) =>
        @api.call command, {"InstanceId.1": @get "_id" }, outcome.e(next).s () =>
          next null, @
    else 
      fn = command

    fn outcome.e(next).s () =>
      @wait { state: state }, next


module.exports = Instance