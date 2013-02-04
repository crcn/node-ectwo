gumbo = require "gumbo"
_ = require "underscore"
ImageModel = require "./image"
outcome = require "outcome"
createInstance = require "../../utils/createInstance"
BaseCollection = require "../base/collection"


###
 A collection of ALL Amazon Machine Images
###

module.exports = class extends BaseCollection

  ###
  ###
  
  constructor: (region) ->
    super region, {
      uniqueKey: "imageId",
      modelClass: ImageModel
    }

  ###
   creates a new instance
  ###

  createInstance: (options, callback) ->


    if typeof options isnt "object"
      throw new Error "options must be an object"

    createInstance @, options, callback


  ###
   Loads the remote collection
  ###

  _load: (onLoad) ->



    @ec2.call "DescribeImages", { "Owner.1": "self" }, outcome.e(onLoad).s (result) =>
      return onLoad(null, []) if not result.imagesSet.item
      images = if result.imagesSet.item not instanceof Array then [result.imagesSet.item] else result.imagesSet.item
      onLoad null, images


