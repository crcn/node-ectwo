outcome = require "outcome"


class KeyPair extends require("../../base/regionModel")
  
  ###
  ###

  _destroy: (next) ->
    @api.call "DeleteKeyPair", { KeyName: @get("name") }, next
      



module.exports = KeyPair