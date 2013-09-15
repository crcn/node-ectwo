outcome = require "outcome"
toarray = require "toarray"
async   = require "async"

###

Server States:

+--------+---------------+
|  Code  |     State     |
+--------+---------------+
|   ?    |    pending    | 
|   ?    |    available  |
+--------+---------------+

###

class Image extends require("../../base/regionModel")

  ###
  ###

  createInstance: (options, next) ->

    if arguments.length is 1
      next    = options
      options = {}

    options.imageId = @get "_id"
    options.tags    = @get("tags")

    @wait { state: "available" }, () =>
      @collection.region.instances.create options, next


  ###
  ###

  migrate: (regions, next) ->
    regions = toarray regions

    @wait { state: "available" }, outcome.e(next).s () =>
      @region.collection.find { name: {$in: regions }}, outcome.e(next).s (regions) =>
        async.each regions, @_migrateToRegion, next

  ###
  ###

  _migrateToRegion: (region, next) =>

    o = outcome.e(next)

    region.api.call "CopyImage", {
      "SourceRegion": @get("region"),
      "SourceImageId": @get("_id"),
      "Description": @get("description") or @get("_id"),
      "Name": @get("name") or @get("_id")
    }, o.s (image) =>
      region.images.waitForOne { _id: image.imageId }, o.s (image) =>
        image.wait { state: "available" }, o.s () =>
          image.tag @get("tags"), next

  ###
  ###

  _destroy: (next) ->
    @api.call "DeregisterImage", { "ImageId": @get("_id") }, next



module.exports = Image