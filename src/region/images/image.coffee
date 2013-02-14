gumbo      = require "gumbo"
stepc      = require "stepc"
outcome    = require "outcome"
allRegions = require "../../utils/regions"
createInstance = require "../../utils/createInstance"
BaseModel  = require "../base/model"

module.exports = class extends BaseModel
   
  ###
    Function: createServer
  
    creates a new server from the AMI

    Parameters:
  ###

  createInstance: (options, callback) ->

    ectwo_log.log "%s: create server", @region.name

    options.imageId = @get "imageId"

    createInstance @region, options, callback

  ###
   TODO
  ###

  getPricing: (callback) ->



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






