gumbo      = require "gumbo"
stepc      = require "stepc"
outcome    = require "outcome"
allRegions = require "../../utils/regions"
createInstance = require "../../utils/createInstance"

module.exports = class extends gumbo.BaseModel
   
  ###
    Function: 

    Parameters:
  ###

  constructor: (collection, @region, item) ->
    super collection, item

  ###
    Function: createServer
  
    creates a new server from the AMI

    Parameters:
  ###

  createInstance: (options, callback) ->

    ectwo_log.log "%s: create server", @region.name

    options.imageId = @get("imageId")

    createInstance @region, options, callback

  ###
  ###

  migrate: (toRegions, callback) ->

  ###
    Function: removes the AMI 

    Parameters:
  ###

  deRegister: (callback) ->
    ectwo_log.log "%s: degister ami %s", @region.name, @get "imageId"
    @_ec2.call "DeregisterImage", { "ImageId": @get("imageId") }, callback






