gumbo = require "gumbo"
_ = require "underscore"
comerr = require "comerr"
outcome = require "outcome"
stepc   = require "stepc"
createImage = require "../../utils/createImage"

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

module.exports = class extends gumbo.BaseModel
  
  ###
  ###

  constructor: (collection, @region, item) ->
    @_ec2 = region.ec2
    item.region = @region.get "name"
    super collection, item

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

      state = @get "instanceState.name"

      # stopped? Perfect - this is the state we want to be in
      # TODO: handle the callback result
      if /stopped/.test state
        @_ec2.call "StartInstances", { "InstanceId.1": @get "instanceId" }, callback
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

    state = @get "instanceState.name"

    if /running/.test state
      @_ec2.call "StopInstances", { "InstanceId.1": @get "instanceId" }, callback
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

  terminate: (callback) ->
    @_runCommand "terminated", _.bind(this.terminate2, this, callback), callback

  ###
  ###

  terminate2: (callback) ->
    @_ec2.call "TerminateInstances", { "InstanceId.1": @get "instanceId" }, callback


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

    stepc.async () =>
        @_ec2.call "CreateImage", { 
          "InstanceId": @get("instanceId"), 
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

    createImage @region, {
      imageId: @get("imageId"),
      flavor: @get("instanceType")
    }, callback


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

    stepc.async () =>

        # first synchronize with EC2 to make sure we're on the right state - super important.
        # If we're on the wrong state, then callback might not ever be called. 

        @_sync @

      , () =>

        if stateTest.test @get "instanceState.name"
          end()
        else
          next()

  ###
    Function: 

    Parameters:
  ###

  _runCommand: (expectedState, runCommand, onComplete) ->

    @_skipIfState expectedState, callback, () =>
      state @get "instanceState.name"

      if /terminated/.test state
        onComplete new comerr.NotFound "The instance has been terminated."
      else
      if not /stopping|stopped|shutting-down|running|pending/.test state
        onComplete new comerr.UnknownError "An unrecognized instance state was returned."
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

      
  ###
    Function: 

    Parameters:
  ###

  _sync: (callback) =>






