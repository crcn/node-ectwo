EventEmitter = require("events").EventEmitter
ServerModel  = require "./model"

module.exports = class extends EventEmitter
  
  ###
    Function: Constructor
    Parameters:
  ###

  constructor: (@target) ->
    @ec2 = target.region.ec2
    @SYNC_TIMEOUT = 1000 * 6 # sync the servers every N minutes

  ###
    Function: start
      Starts the synchronization process

    Parameters:
  ###

  load: (callback) ->  

    #callback must exist
    if not callback
      callback = () -> # do nothing

    @on "update", callback

    clearInterval @syncInterval

    # start the update interval
    @syncInterval = setInterval((() => 
      @update()), 
    @SYNC_TIMEOUT)

    @update()

  ###
    Function: updates 

    Updates the collection with the newest server info from EC2.
    Note - this is really only important for inserting NEW ec2 instances, since
    each server does a fetch for new information periodically

    Parameters:
  ###

  update: (callback) ->
    update2: () =>
      @emit "update"
      callback.apply null, arguments

  ###
    Function: 

    Parameters:
  ###

  update2: () ->






