Region = require "./region"

class Regions extends require("./base/collection")

  ###
  ###

  constructor: (@ectwoOptions) ->
    super { modelClass: Region }
    @_regions = ectwoOptions.regions or require("./utils/allRegions")

  ###
  ###

  toString: () -> "regions"

  ###
  ###

  _load2: (options, next) ->
    next null, @_regions.map (name) -> { _id: name, name: name }

module.exports = Regions