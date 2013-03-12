_              = require "underscore"
Tags           = require "../tags"
gumbo          = require "gumbo"
toarray        = require "toarray"
ImageModel     = require "./image"
BaseCollection = require "../base/collection"
createInstance = require "../../utils/createInstance"

###
 A collection of ALL Amazon Machine Images
###

module.exports = class extends BaseCollection

  ###
  ###
  
  constructor: (region) ->
    super region, {
      modelClass: ImageModel,
      name: "image"
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
      search = { "ImageId.1": options._id }

    @ec2.call "DescribeImages", search, @_o.e(onLoad).s (result) =>
      images = toarray(result.imagesSet.item).
      map((image) ->
        {
          _id: image.imageId,
          state: image.imageState,
          ownerId: image.imageOwnerId,
          isPublic: image.isPublic,
          name: image.name,
          type: image.imageType,
          kernelId: image.kernelId,
          platform: (image.platform or "linux").toLowerCase()
          architecture: image.architecture, # i386, x86_64
          description: image.description,
          virtualizationType: image.virtualizationType,
          tags: Tags.transformTags image
        }
      )

      # snapshots should be loaded at the same time since there's a 1-1 relationship
      @region.snapshots.load () ->
        onLoad null, images



