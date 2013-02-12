
BaseModel  = require "../base/model"

module.exports = class extends BaseModel

  ###
  ###

  _destroy: (callback) ->
    @_ec2.call "ReleaseAddress", { PublicIp: @get "publicIp" }, callback

  ###
  ###

  associate: (instanceOrInstanceId) ->
