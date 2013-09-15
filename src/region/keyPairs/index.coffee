KeyPair = require "./keyPair"
toarray        = require "toarray"
outcome = require "outcome"


class KeyPairs extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: KeyPair, region: region }

  ###
  ###

  _load2: (options, next) ->

    search = {}

    if options._id
      search["KeyName.1"] = options._id


    @region.api.call "DescribeKeyPairs", search, outcome.e(next).s (result) =>
      keySets = toarray(result.keySet.item).
      map((keySet) =>
        {
          _id: keySet.keyName,
          name: keySet.keyName,
          region: @region.get("name"),
          fingerprint: keySet.keyFingerprint
        }
      )

      next null, keySets

  ###
  ###

  create: (optionsOrName, next) ->

    if typeof optionsOrName is "string"
      options = { name: optionsOrName }
    else
      options = optionsOrName

    onKey = outcome.e(next).s (result) =>

      @waitForOne { name: options.name }, outcome.e(next).s (keyPair) ->

        # only gets set once
        keyPair.set "material", result.keyMaterial

        next null, keyPair

    if options.material
      @region.api.call "ImportKeyPair", { KeyName: options.name, PublicKeyMaterial: options.material }, onKey
    else 
      @region.api.call "CreateKeyPair", { KeyName: options.name }, onKey




module.exports = KeyPairs