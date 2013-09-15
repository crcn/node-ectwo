bindable   = require "bindable"
Regions    = require "./regions"
fastener   = require "./fastener"


class ECTwo extends bindable.Object

  ###
  ###

  constructor: (@options) ->
    super()
    @regions  = new Regions @options
    @fastener = fastener

  ###
  ###

  chain: () ->
    fastener.wrap "ectwo", @

  ###
  ###

  use: (plugin) -> plugin @



module.exports = (config) ->
  new ECTwo config

module.exports.fastener = fastener
module.exports.regions = require("./utils/allRegions");