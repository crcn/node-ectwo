gumbo = require "gumbo"
outcome = require "outcome"

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

  reload: (callback) -> @_sync callback

  ###
    Function: 

    Parameters:
  ###

  _sync: (callback) ->
    @collection.sync.loadOne @get("_id"), callback


  ###
  ###

  destroy: (callback) ->
    @_destroy outcome.e(callback).s () =>
      @_remove()
      callback()

  ###
  ###

  _remove: () ->
    @collection.remove({ _id: @get("_id") }).sync()