
BaseModel  = require "../base/model"
waitForCollectionSync = require "../../utils/waitForCollectionSync"
findOneOrErr = require "../../utils/findOneOrErr"

module.exports = class extends BaseModel

  ###
  ###

  _destroy: (callback) ->
    @_ec2.call "ReleaseAddress", { PublicIp: @get "publicIp" }, callback

  ###
  ###

  disassociate: (callback) ->

    load = (callback) =>
      @_ec2.call "DisassociateAddress", { PublicIp: @get "publicIp" }, outcome.e(callback).s (result) =>
        @reload callback

    waitForCollectionSync { publicIp: @get("publicIp"), instanceId: @get("instanceId") }, @collection, false, load, callback
    
  ###
  ###

  getInstance: (callback) ->
    findOneOrErr @region.instances, { _id: @get("instanceId") }, callback

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
      
