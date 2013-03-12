async          = require "async"
toarray        = require "toarray"
Pricing        = require "./pricing"
SpotRequest    = require "./spotRequest"
BaseCollection = require "../base/collection"

###
###

module.exports = class extends BaseCollection
  
  ###
  ###

  constructor: (region) ->
    @pricing = new Pricing region
    @pricing.load()
    super region, {
      modelClass: SpotRequest,
      name: "spotRequest"
    }

  create: (options, callback) ->

    realOps = {
      "SpotPrice": options.price,
      "Type": "one-time",
      "LaunchSpecification.ImageId": options.imageId,
      "LaunchSpecification.InstanceType": options.type
    }

    @ec2.call "RequestSpotInstances", realOps, @_o.e(callback).s (result) =>
      @syncAndFindOne { _id: result.spotInstanceRequestSet.item.spotInstanceRequestId }, callback
  ###
  ###

  _load: (options, onLoad) ->

    search = {}

    if options._id
      search["SpotInstanceRequestId.1"] = options._id

    
    @ec2.call "DescribeSpotInstanceRequests", search, @_o.e(onLoad).s (result) ->

      requests = toarray(result.spotInstanceRequestSet.item).
      map((item) ->
        {
          _id: item.spotInstanceRequestId,
          price: Number(item.spotPrice),
          type: item.type,
          state: item.state,
          instance: {
            imageId: item.launchSpecification.imageId,
            type: item.launchSpecification.instanceType
          },
          createdAt: new Date(item.createTime),
          description: item.productDescription
        }
      )

      if not options._id
        requests = requests.filter((request) ->
          request.state isnt "cancelled"
        )


      onLoad null, requests
      
    
