
BaseModel  = require "../base/model"
waitForCollectionSync = require "../../utils/waitForCollectionSync"

module.exports = class extends BaseModel

  ###
  ###

  _destroy: (callback) ->
    @_ec2.call "ReleaseAddress", { PublicIp: @get "publicIp" }, callback

  ###
  ###

  disassociate: (callback) ->
    @_ec2.call "DisassociateAddress", { PublicIp: @get "publicIp" }, outcome.e(callback).s (result) =>
      @reload () =>
        callback null, result
  ###
  ###

  getInstance: (callback) ->
    @region.instances.findOne({ _id: @get("instanceId") }).exec callback

  ###
  ###

  associate: (instanceOrInstanceId, callback) ->
    instanceId = if typeof instanceOrInstanceId is "object" then instanceOrInstanceId.get("_id") else instanceOrInstanceId

    load = (callback) =>
      @_ec2.call "AssociateAddress", {
        PublicIp: @get("publicIp"),
        InstanceId: instanceId
      }, () =>
        @reload callback


    waitForCollectionSync { publicIp: @get("publicIp"), instanceId: instanceId }, @collection, true, load, callback
      
