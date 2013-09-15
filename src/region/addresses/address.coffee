outcome = require "outcome"


class Address extends require("../../base/regionModel")

  ###
    {
      ports: [
        {
          from: 80,
          to: 8080,
          type: "tcp",
          ranges: ["0.0.0.0/0"]
        }
      ]
    }
  ###

  authorize: (optionsOrPort, next) ->
    @_runCommand "AuthorizeSecurityGroupIngress", optionsOrPort, next

  ###
  ###

  revoke: (optionsOrPort, next) ->
    @_runCommand "RevokeSecurityGroupIngress", optionsOrPort, next

  ###
  ###

  disassociate: (next) ->
    @api.call "DisassociateAddress", { PublicIp: @get "publicIp" }, outcome.e(callback).s (result) =>
      @reload callback

  ###
  ###

  associate: (instanceOrInstanceId, next) ->
    instanceId = if typeof instanceOrInstanceId is "object" then instanceOrInstanceId.get("_id") else instanceOrInstanceId

    @api.call "AssociateAddress", {
      PublicIp: @get("publicIp"),
      InstanceId: instanceId
    }, () =>
      @reload next
  
  ###
  ###

  _destroy: (next) ->
    @api.call "ReleaseAddress", { PublicIp: @get "publicIp" }, next
      



module.exports = Address