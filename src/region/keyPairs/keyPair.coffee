gumbo = require "gumbo"
BaseModel = require "../base/model"

module.exports = class extends BaseModel

  ###
   destroys the keypair
  ###


  destroy: (callback) ->
    @_ec2.call "DeleteKeyPair", { KeyName: @get("name") }, outcome.e(callback).s () =>
      @collection.load callback