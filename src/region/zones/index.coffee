bindable      = require "bindable"
outcome       = require "outcome"
toarray       = require "toarray"

class Zones extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: bindable.Object, region: region }

  ###
  ###

  _load2: (options, next) ->
    @api.call "DescribeAvailabilityZones", {}, outcome.e(next).s (result) =>
      next null, toarray(result.availabilityZoneInfo.item).map (item) ->
        _id: item.zoneName
        name: item.zoneName
        state: item.zoneState
        region: item.regionName




module.exports = Zones