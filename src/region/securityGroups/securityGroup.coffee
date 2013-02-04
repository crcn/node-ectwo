gumbo = require "gumbo"

module.exports = class extends gumbo.BaseModel
  
  ###
  ###

  constructor: (collection, @region, item) ->
    @_ec2 = region.ec2
    # console.log item
    super collection, item


  ###
   destroys the keypair
  ###


  destroy: (callback) ->
    @_ec2.call "DeleteKeyPair", { KeyName: @get "keyName" }, () =>
      @collection.load callback