gumbo                 = require "gumbo"
BaseModel             = require "../base/model"
waitForCollectionSync = require "../../utils/waitForCollectionSync"

###
###

module.exports = class extends BaseModel
  
  ###
  ###

  _destroy: (callback) ->

    load = (callback) =>
      @_ec2.call "CancelSpotInstanceRequests", { "SpotInstanceRequestId.1": @get("_id") }, () =>
        @collection.load callback

    # spot requests aren't removed immediately, so we need to persistently reload the collection
    # until it is.
    waitForCollectionSync {_id: @get("_id") }, @collection, false, load, callback
