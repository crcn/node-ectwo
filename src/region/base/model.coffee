gumbo             = require "gumbo"
waitUntilItemSync = require "../../utils/waitUntilItemSync"

###
###

module.exports = class extends gumbo.BaseModel

  ###
    Function: 

    Parameters:
  ###

  constructor: (collection, @region, item) ->
    @_ec2 = region.ec2
    super collection, item

    # re-route any error to this model (event emitter)
    @_o = outcome.e @
    @logger = collection.logger.child "#{item._id}"

  ###
  ###

  reload: (callback = (()->)) -> @_sync callback

  ###
    Function: 

    Parameters:
  ###

  _sync: (callback) ->
    @collection.loader().loadOne @get("_id"), callback

  ###
  ###

  destroy: (callback) ->

    # DON'T DO THIS! 
    # @_remove()
    @logger.info "destroy"
    
    @_destroy @_o.e(callback).s () =>

      @logger.info "destroyed"

      # remove IMMEDIATELY so that this model cannot be reloaded
      @_remove()
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
    @collection.remove({ _id: @get("_id") }, (()->))