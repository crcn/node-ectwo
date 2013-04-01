Tags           = require "../tags"
stepc          = require "stepc"
gumbo          = require "gumbo"
async          = require "async"
toarray        = require "toarray"
outcome        = require "outcome"
BaseModel      = require "../base/model"
allRegions     = require "../../utils/regions"
tagsToObject   = require "../../utils/tagsToObject"
findOneOrErr   = require "../../utils/findOneOrErr"
createInstance = require "../../utils/createInstance"
copyTags       = require "../../utils/copyTags"

###

Server States:

+--------+---------------+
|  Code  |     State     |
+--------+---------------+
|   ?    |    pending    | 
|   ?    |    available  |
+--------+---------------+

###

module.exports = class extends BaseModel
  
  ###
  ###

  constructor: (collection, region, item) ->
    super collection, region, item
    @tags = new Tags @

  ###
    Function: createServer
  
    creates a new server from the AMI

    Parameters:
  ###

  createInstance: (options, callback) ->

    if arguments.length is 1
      callback = options
      options = {}

    @logger.info "create server #{@get('_id')}"


    options.imageId = @get "_id"
    options.tags = tagsToObject(@get("tags") or [])

    @waitUntilSync { state: "available" }, () =>
      createInstance @region, options, callback

  ###
  ###

  getSnapshot: (callback) ->

    # reload - the snapshot might not exist - since collections are synchronized every N
    # minutes
    @region.snapshots.syncAndFindOne { imageId: @get("_id") }, callback

  ###
  ###

  getOneSpotPricing: (search, callback) ->

    if typeof search is "function"
      callback = search
      search = {}

    search.platform = @get "platform"

    findOneOrErr @region.spotRequests, search, callback

  ###
  ###

  createSpotRequest: (options, callback) ->
    options.imageId = @get "imageId"
    @region.spotRequests.create options, callback

  ###
   TODO - this needs to be a job. Migrating instances
   may take a long time, and we can't have this shoved into memory. - perhaps
   copy a snapshot & provide directions for initialization in the description.
  ###

  migrate: (regions, callback) ->

    o = @_o.e callback

    @logger.info "migrate"

    @_waitUntilState "available", o.s () =>
      async.mapSeries toarray(regions), @_migrateToRegion, callback

  ###
  ###

  _migrateToRegion: (region, next) =>

    o = @_o.e next


    @logger.info "migrate to region #{region.get("name")}"

    # copy the image - this is a PULL request
    region.ec2.call "CopyImage", {
      "SourceRegion": @get("region"),
      "SourceImageId": @get("_id"),
      "Description": @get("description") or @get("_id"),
      "Name": @get("name") or @get("_id")
    }, o.s (image) =>

      # and wait for the image to show up in the target region
      region.images.syncAndFindOne { _id: image.imageId }, o.s (image) =>

        # finally, copy the tags over from the ORIGINAL image
        copyTags @, image, o.s () =>

          # wait until the new image is available
          image._waitUntilState "available", o.s () ->
            next null, image



  ###
    Waits until the server reaches this particular state
    Parameters:
  ###

  _waitUntilState: (state, callback) ->
    @waitUntilSync { state: state }, callback

  ###
    Function: removes the AMI 

    Parameters:
  ###

  _destroy: (callback) ->
    o = @_o.e callback
    @_ec2.call "DeregisterImage", { "ImageId": @get "_id" }, callback






