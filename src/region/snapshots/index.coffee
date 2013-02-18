BaseCollection = require "../base/collection"
SpotRequest    = require "./spotRequest"
outcome        = require "outcome"
toarray        = require "toarray"
SnapShot       = require "./snapshot"

module.exports = class extends BaseCollection
  
  ###
  ###

  constructor: (region) ->
    super region, {
      modelClass: SnapShot
    }


  _load: (options, onLoad) ->
  
      
    
