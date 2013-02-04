gumbo = require "gumbo"
_     = require "underscore"
KeyPair = require "./keyPair"
BaseCollection = require "../base/collection"
outcome = require "outcome"

module.exports = class extends BaseCollection 
  
  ###
  ###

  constructor: (region) ->
    super region, {
      uniqueKey: "keyName",
      modelClass: KeyPair
    }


  ###
  ###

  _load: (onLoad) ->
    @ec2.call "DescribeKeyPairs", {}, outcome.e(onLoad).s (result) ->
      return onLoad(null, []) if not result.keySet.item

      keySets = if result.keySet.item instanceof Array then result.keySet.item else [result.keySet.item]

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




