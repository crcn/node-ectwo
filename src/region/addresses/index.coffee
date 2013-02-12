BaseCollection = require "../base/collection"
AddressModel = require "./address"
outcome      = require "outcome"
toarray      = require "toarray"

module.exports = class extends BaseCollection

  ###
  ###

  
  constructor: (region) ->
    super region, {
      modelClass: AddressModel
    }

  ###
  ###

  allocate: (callback) ->
    @ec2.call "AllocateAddress", {}, outcome.e(callback).s (result) =>
      @syncAndFindOne { publicIp: result.publicIp }, callback


  ###
  ###

  _load: (options, callback) ->

    search = {}

    if options._id
      search["AllocationId.1"] = options._id


    @ec2.call "DescribeAddresses", search, outcome.e(callback).s (result) ->

      addresses = toarray(result.addressesSet.item).
      map ((item) ->

        if typeof item.instanceId is "object"
          instanceId = undefined
        else 
          instanceId = item.instanceId

        {
          _id: item.publicIp,
          publicIp: item.publicIp,
          domain: item.domain,
          instanceId: instanceId
        }
      )
      callback null, addresses
