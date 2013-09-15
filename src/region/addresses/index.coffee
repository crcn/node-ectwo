outcome = require "outcome"
Address = require "./address"
toarray = require "toarray"

class Addresses extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: Address, region: region }

  ###
  ###

  create: (next) ->
    @region.api.call "AllocateAddress", {}, outcome.e(next).s (result) =>
      @waitForOne { publicIp: result.publicIp }, next

  ###
  ###

  _load2: (options, next) ->
    search = {}

    if options._id
      search["PublicIp.1"] = options._id

    @region.api.call "DescribeAddresses", search, outcome.e(next).s (result) =>

      addresses = toarray(result.addressesSet.item).
      map ((item) =>

        if typeof item.instanceId is "object"
          instanceId = undefined
        else 
          instanceId = item.instanceId

        {
          _id: item.publicIp,
          publicIp: item.publicIp,
          domain: item.domain,
          region: @region.get("name"),
          instanceId: instanceId
        }
      )
      next null, addresses



module.exports = Addresses