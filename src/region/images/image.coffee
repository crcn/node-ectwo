gumbo      = require "gumbo"
stepc      = require "stepc"
outcome    = require "outcome"
allRegions = require "../../utils/regions"
createInstance = require "../../utils/createInstance"
BaseModel  = require "../base/model"
Tags           = require "../tags"
tagsToObject = require "../../utils/tagsToObject"
toarray = require "toarray"
async = require "async"
Migrator = require "./migrator"

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

    ectwo_log.log "%s: create server", @region.name

    options.imageId = @get "_id"
    options.tags = tagsToObject(@get("tags") or [])

    @waitUntilSync { state: "available" }, () =>
      createInstance @region, options, callback

  ###
  ###

  getSnapshot: (callback) ->

    # reload - the snapshot might not exist - since collections are synchronized every N
    # minutes
    @region.snapshots.load outcome.e(callback).s () =>
      @region.snapshots.findOne { imageId: @get("_id") }, outcome.e(callback).s (snapshot) ->
        return callback new Error("unable to fetch snapshot") if not snapshot
        callback null, snapshot

  ###
  ###

  getOneSpotPricing: (search, callback) ->

    if typeof search is "function"
      callback = search
      search = {}

    search.platform = @get "platform"

    @region.spotRequests.pricing.findOne search, callback

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
    @getSnapshot outcome.e(callback).s (snapshot) =>
      async.map(toarray(regions), ((region, next) =>

        # first need to copy the snapshot
        region.snapshots.copy {
          "_id": snapshot.get("_id"),
          "region": snapshot.get("region"),
          "description": @get("description")
        }, outcome.e(next).s (snapshot) =>
            
          next null, new Migrator @, snapshot

      ), callback)

  ###
    Function: removes the AMI 

    Parameters:
  ###

  destroy: (callback) ->
    @_ec2.call "DeregisterImage", { "ImageId": @get "_id" }, callback






