_              = require "underscore"
gumbo          = require "gumbo"
KeyPair        = require "./keyPair"
toarray        = require "toarray"
BaseCollection = require "../base/collection"

module.exports = class extends BaseCollection 
  
  ###
  ###

  constructor: (region) ->
    super region, {
      modelClass: KeyPair
      name: "keyPair"
    }


  ###
  ###

  _load: (options, onLoad) ->

    search = { }

    if options._id
      search["KeyName.1"] = options._id

    @ec2.call "DescribeKeyPairs", search, @_o.e(onLoad).s (result) ->
      keySets = toarray(result.keySet.item).
      map((keySet) ->
        {
          _id: keySet.keyName,
          name: keySet.keyName,
          fingerprint: keySet.keyFingerprint
        }
      )

      onLoad null, keySets


  ###
  ###

  create: (optionsOrName, callback) ->

    if typeof optionsOrName is "string"
      options = { name: optionsOrName }
    else
      options = optionsOrName

    onKey = @_o.e(callback).s (result) =>
      @syncAndFindOne { name: options.name }, callback


    if options.material
      @ec2.call "ImportKeyPair", { KeyName: options.name, PublicKeyMaterial: options.material }, onKey
    else 
      @ec2.call "CreateKeyPair", { KeyName: options.name }, onKey




