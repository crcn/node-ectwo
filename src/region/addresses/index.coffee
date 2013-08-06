
outcome        = require "outcome"
toarray        = require "toarray"
AddressModel   = require "./address"
BaseCollection = require "../base/collection"

module.exports = class extends BaseCollection

  ###
  ###

  
  constructor: (region) ->
    super region, {
      modelClass: AddressModel,
      name: "addresses"
    }

  ###
  ###

  allocate: (callback) ->
    @logger.info "allocate"
    @ec2.call "AllocateAddress", {}, @_o.e(callback).s (result) =>
      @logger.info "allocated publicIp=#{result.publicIp}"
      @syncAndFindOne { publicIp: result.publicIp }, callback

  ###
  ###

  _load: (options, callback) ->

    search = {}

    if options._id
      search["PublicIp.1"] = options._id

    @ec2.call "DescribeAddresses", search, @_o.e(callback).s (result) ->

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
