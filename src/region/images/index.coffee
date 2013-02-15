gumbo = require "gumbo"
_ = require "underscore"
ImageModel = require "./image"
outcome = require "outcome"
createInstance = require "../../utils/createInstance"
BaseCollection = require "../base/collection"
toarray = require "toarray"


###
 A collection of ALL Amazon Machine Images
###

module.exports = class extends BaseCollection

  ###
  ###
  
  constructor: (region) ->
    super region, {
      modelClass: ImageModel
    }

  ###
   creates a new instance
  ###

  createInstance: (options, callback) ->


    if typeof options isnt "object"
      throw new Error "options must be an object"

    createInstance @region, options, callback


  ###
   Loads the remote collection
  ###

  _load: (options, onLoad) ->

    search = { "Owner.1": "self" }

    if options._id
      search["ImageId.1"] = options._id

    @ec2.call "DescribeImages", search, outcome.e(onLoad).s (result) =>
      images = toarray(result.imagesSet.item).
      map((image) ->
        {
          _id: image.imageId,
          state: image.imageState,
          ownerId: image.imageOwnerId,
          isPublic: image.isPublic,
          name: image.name,
          type: image.imageType,
          paltform: (image.platform or "linux").toLowerCase()
          architecture: image.architecture, # i386, x86_64
          description: image.description,
          virtualizationType: image.virtualizationType
        }
      )

      onLoad null, images



