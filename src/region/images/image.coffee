outcome = require "outcome"

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

  _destroy: (next) ->
    @api.call "DeregisterImage", { "ImageId": @get("_id") }, next



module.exports = Image