
BaseModel  = require "../base/model"
waitForCollectionSync = require "../../utils/waitForCollectionSync"

module.exports = class extends BaseModel

  ###
  ###

  _destroy: (callback) ->
    @_ec2.call "ReleaseAddress", { PublicIp: @get "publicIp" }, callback

  ###
  ###

  associate: (instanceOrInstanceId, callback) ->
    instanceId = if typeof instanceOrInstanceId is "object" then instanceOrInstanceId.get("_id") else instanceOrInstanceId

    load = (callback) =>
      @_ec2.call "AssociateAddress", {
        PublicIp: @get("publicIp"),
        InstanceId: instanceId
      }, () =>
        @reload () =>
          callback()

    console.log { publicIp: @get("publicIp"), instanceId: instanceId }

    waitForCollectionSync { publicIp: @get("publicIp"), instanceId: instanceId }, @collection, true, load, callback
      
  ###
  ###

  deassociate: (callback) ->
