outcome = require "outcome"
toarray = require "toarray"
Image   = require "./image"

class Images extends require("../../base/collection")

  ###
  ###

  constructor: (@region) ->
    super { modelClass: Image }

  ###
  ###

  _load2: (options, next) ->

    search = { "Owner.1": "self" }

    if options._id
      search = { "ImageId.1": options._id }

    @region.api.call "DescribeImages", search, outcome.e(next).s (result) =>

      images = toarray(result.imagesSet.item).
      map((image) =>
        {
          _id                 : image.imageId,
          state               : image.imageState,
          ownerId             : image.imageOwnerId,
          isPublic            : image.isPublic,
          region              : @region.get("_id"),
          name                : image.name,
          type                : image.imageType,
          kernelId            : image.kernelId,
          platform            : (image.platform or "linux").toLowerCase()
          architecture        : image.architecture, # i386, x86_64
          description         : image.description,
          virtualizationType  : image.virtualizationType
        }
      )


      next null, images

module.exports = Images