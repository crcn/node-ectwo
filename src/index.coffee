bindable   = require "bindable"
Regions    = require "./regions"
fastener   = require "./fastener"


class ECTwo extends bindable.Object

  ###
  ###

  constructor: (@options) ->
    super()
    @regions = new Regions @options

  ###
  ###

  chain: () ->
    fastener.wrap "ectwo", @



module.exports = (config) ->
  new ECTwo config

module.exports.fastener = fastener