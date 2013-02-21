gumbo = require "gumbo"
outcome = require "outcome"
waitUntilItemSync = require "../../utils/waitUntilItemSync"

module.exports = class extends gumbo.BaseModel

  ###
    Function: 

    Parameters:
  ###

  constructor: (collection, @region, item) ->
    @_ec2 = region.ec2
    super collection, item

  ###
  ###

  reload: (callback = (()->)) -> @_sync callback


  ###
    Function: 

    Parameters:
  ###

  _sync: (callback) ->
    @collection.sync.loadOne @get("_id"), callback


  ###
  ###

  destroy: (callback = (()->)) ->

    # remove IMMEDIATELY so that this model cannot be reloaded
    @_remove()
    
    @_destroy outcome.e(callback).s () =>
      callback()

  ###
  ###

  waitUntilSync: (search, callback) ->
    waitUntilItemSync @, search, callback

  ###
  ###

  _skipIfSynced: (search, end, callback) ->
    waitUntilItemSync.skipIfSynced @, search, end, callback

  ###
  ###

  _remove: () ->
    @collection.remove({ _id: @get("_id") }).sync()