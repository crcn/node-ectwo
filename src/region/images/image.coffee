Tags           = require "../tags"
stepc          = require "stepc"
gumbo          = require "gumbo"
async          = require "async"
toarray        = require "toarray"
outcome        = require "outcome"
Migrator       = require "./migrators/migrator"
Migrators      = require "./migrators"
BaseModel      = require "../base/model"
allRegions     = require "../../utils/regions"
tagsToObject   = require "../../utils/tagsToObject"
findOneOrErr   = require "../../utils/findOneOrErr"
createInstance = require "../../utils/createInstance"

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

    @logger.info "migrate"

    o = @_o.e callback

    @getSnapshot o.s (snapshot) =>

      async.map(toarray(regions), ((region, next) =>

        # first need to copy the snapshot
        region.snapshots.copy {
          "_id": snapshot.get("_id"),
          "region": snapshot.get("region"),
          "description": @get("description")
        }, outcome.e(next).s (snapshot) =>
            
          next null, new Migrator @, snapshot

      ), o.s (migrators) =>
        callback null, new Migrators @, migrators
      )

  ###
    Function: removes the AMI 

    Parameters:
  ###

  destroy: (callback) ->
    o = @_o.e callback
    @_ec2.call "DeregisterImage", { "ImageId": @get "_id" }, callback






