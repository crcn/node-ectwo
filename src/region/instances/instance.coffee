gumbo = require "gumbo"
_ = require "underscore"
comerr = require "comerr"
outcome = require "outcome"
stepc   = require "stepc"
createInstance = require "../../utils/createInstance"
BaseModel  = require "../base/model"

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
+--------+---------------+


###

module.exports = class extends BaseModel

  ###
    Function: start
      Starts the server. Note: if the server is stopping, ectwo will wait
      until the server has stopped completely before running the "start" command

    Parameters:
      callback - Called once the srver has properly started
  ###

  start: (callback) -> 
    # @_skipIfState "running", callback, _.bind this.start2, this, callback
    @_runCommand "running", _.bind(this.start2, this, callback), callback


  ###
    secondary start function that bypasses the "running" check
  ###

  start2: (callback) ->

      state = @get "state"

      # stopped? Perfect - this is the state we want to be in
      # TODO: handle the callback result
      if /stopped/.test state
        @_ec2.call "StartInstances", { "InstanceId.1": @get "_id" }, callback
      else

      # server is shutting down
      if /shutting-down|stopping/.test state
        @_waitUntilState "stopped|terminated", () => @start callback
      else

      # server is still initializing, it'll startup in a bit
      # TODO - pending might throw an error
      if /pending/.test state
        @_waitUntilState "running", callback

  ###
    Function: stop
      Stops the server. 

    Parameters:
      callback - Called once the server has stopped
  ###


  stop: (callback) ->
    @_runCommand "stopped", _.bind(this.stop2, this, callback), callback

  ###
  ###

  stop2: (callback) ->

    state = @get "state"

    if /running/.test state
      @_ec2.call "StopInstances", { "InstanceId.1": @get "_id" }, callback
    else
    if /stopping|shutting-down/.test state
      @_waitUntilState "stopped|terminated", () => @stop callback
    else
    if /pending/.test state
      @_waitUntilState "running", () => @stop callback


  ###
    Function: restart

    Parameters:
  ###

  restart: (callback) ->
    @stop outcome.e(callback).s () => @start callback

  ###
    Function: terminate

    Terminates the EC2 instance

    Parameters:
  ###

  destroy: (callback) ->
    @_runCommand "terminated", _.bind(this.terminate2, this, callback), callback

  ###
  ###

  terminate2: (callback) ->
    @_ec2.call "TerminateInstances", { "InstanceId.1": @get "_id" }, callback


  ###
    Function: getAMI

    Fetches the AMI of this instance

    Parameters:
  ###

  getImage: (callback) ->
    # todo - image might not be in the collection - needs to be fetched remotely

  ###
    Function: createAMI

    Parameters:
      callback - called once the AMI is created

    Returns:
      The AMI
  ###

  createImage: (options, callback) -> 
    o = outcome.e callback
    self = @

    stepc.async () ->
        self._ec2.call "CreateImage", { 
          "InstanceId": @get("_id"), 
          name: new Date().toString()
        }, @
      , o.s (image) ->

  ###
    Function: clone

      Clones the server based on the AMI id, *and* the instance flavor (c1.medium perhaps)

    Parameters:

    Returns:
      The new EC2 instance
  ###

  clone: (callback) -> 
    o = outcome.e callback
    self = @

    ## TODO - sync & find one
    createInstance @region, {
      imageId: @get("imageId"),
      flavor: @get("type")
    }, result


  ###
    Function: refresh

    Refreshes the server from information about the EC2 Instance. Note - this function
    is called everytime you want to invoke a command against the server to make sure ECTwo can
    handle the server properly depending on its current state. starting an instance for instance 
    requires that an instance is in the "stopped" state.

    Parameters:
      callback
  ###

  refresh: (callback) ->


  ###
   flow control helper that skips a method if the server
   is already running in the target state
  ###

  _skipIfState: (state, end, next) ->

    stateTest = new RegExp state
    self = @

    stepc.async () ->

        # first synchronize with EC2 to make sure we're on the right state - super important.
        # If we're on the wrong state, then callback might not ever be called. 

        self._sync @

      , () =>

        if stateTest.test @get "state"
          end()
        else
          next()

  ###
    Function: 

    Parameters:
  ###

  _runCommand: (expectedState, runCommand, callback) ->

    @_skipIfState expectedState, callback, () =>
      state = @get "state"


      if /terminated/.test state
        callback new comerr.NotFound "The instance has been terminated."
      else
      if not /stopping|stopped|shutting-down|running|pending/.test state
        callback new comerr.UnknownError "An unrecognized instance state was returned."
      else
        runCommand()

  ###
    Waits until the server reaches this particular state
    Parameters:
  ###

  _waitUntilState: (state, callback) ->

    checkState = () =>
      @_skipIfState state, callback, () ->
          setTimeout checkState, 1000 * 5

    checkState()








