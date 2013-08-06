toarray        = require "toarray"
Pricing        = require "./pricing"
BaseCollection = require "../../base/collection"

###
###

module.exports = class extends BaseCollection
  
  ###
  ###

  constructor: (region) ->
    super region, {
      modelClass: Pricing,
      timeout: 1000 * 60,
      name: "pricing"
    }

    
  ###
  ###

  _load: (options, onLoad) ->
    @ec2.call "DescribeSpotPriceHistory", {}, @_o.e(onLoad).s (result) ->

      pricing = toarray(result.spotPriceHistorySet.item).
      map((price) ->
        os = getOS(price.productDescription)
        {
          _id: price.instanceType + "-" + os,
          type: price.instanceType,
          platform: os,
          timestamp: new Date(price.timestamp),
          price: Number(price.spotPrice),
          description: price.productDescription
        }
      )

      onLoad null, pricing



getOS = (desc) ->
  desc = desc.toLowerCase()
  oss = {
    "linux/unix": "linux",
    "linux/unix (amazon vpc)": "linux-vpc"
    "windows": "windows",
    "windows (amazon vpc)": "windows-vpc",
    "suse linux": "suse-linux",
    "suse linux (amazon vpc)": "suse-linux-vpc",
  }

  return oss[desc] or desc