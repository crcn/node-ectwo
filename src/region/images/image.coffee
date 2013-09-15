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

class Image extends require("../../base/model")

  ###
  ###

  createInstance: (options, next) ->

    if arguments.length is 1
      next    = options
      options = {}

    options.imageId = @get "_id"

    @wait { state: "available" }, () =>
      @collection.region.createInstance options, next

  ###
  ###

  _destroy: (next) ->
    @api.call "DeregisterImage", { "ImageId": @get("_id") }, next



module.exports = Image