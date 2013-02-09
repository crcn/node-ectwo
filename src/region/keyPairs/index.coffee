gumbo = require "gumbo"
_     = require "underscore"
KeyPair = require "./keyPair"
BaseCollection = require "../base/collection"
outcome = require "outcome"
toarray = require "toarray"

module.exports = class extends BaseCollection 
  
  ###
  ###

  constructor: (region) ->
    super region, {
      modelClass: KeyPair
    }


  ###
  ###

  _load: (options, onLoad) ->

    search = { }

    if options._id
      search["KeyName.1"] = options._id

    @ec2.call "DescribeKeyPairs", search, outcome.e(onLoad).s (result) ->
      keySets = toarray(result.keySet.item).
      map((keySet) ->
        {
          _id: keySet.keyName,
          name: keySet.name,
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

    onKey = outcome.e(callback).s (result) =>
      @syncAndFindOne { keyName: options.name }, callback


    if options.material
      @ec2.call "ImportKeyPair", { KeyName: options.name, PublicKeyMaterial: options.material }, onKey
    else 
      @ec2.call "CreateKeyPair", { KeyName: options.name }, onKey




