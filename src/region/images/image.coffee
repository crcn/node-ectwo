gumbo      = require "gumbo"
stepc      = require "stepc"
outcome    = require "outcome"
allRegions = require "../../utils/regions"
createInstance = require "../../utils/createInstance"
BaseModel  = require "../base/model"
Tags           = require "../tags"
tagsToObject = require "../../utils/tagsToObject"

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

    ectwo_log.log "%s: create server", @region.name

    options.imageId = @get "imageId"
    options.tags = tagsToObject(@get("tags"))

    createInstance @region, options, callback

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
   TODO
  ###

  migrate: (toRegions, callback) ->

  ###
    Function: removes the AMI 

    Parameters:
  ###

  destroy: (callback) ->
    @_ec2.call "DeregisterImage", { "ImageId": @get "_id" }, callback






