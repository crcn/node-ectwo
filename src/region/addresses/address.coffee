outcome = require "outcome"


class Address extends require("../../base/regionModel")

  ###
  ###

  disassociate: (next) ->
    @api.call "DisassociateAddress", { PublicIp: @get "publicIp" }, outcome.e(next).s (result) =>
      @reload next

  ###
  ###

  associate: (instanceOrInstanceId, next) ->
    instanceId = if typeof instanceOrInstanceId is "object" then instanceOrInstanceId.get("_id") else instanceOrInstanceId

    @api.call "AssociateAddress", {
      PublicIp: @get("publicIp"),
      InstanceId: instanceId
    }, () =>

      # reload the instances so it gets the updated value
      @region.instances.reload () =>
        @reload next
  
  ###
  ###

  _destroy: (next) ->
    @api.call "ReleaseAddress", { PublicIp: @get "publicIp" }, next
      



module.exports = Address