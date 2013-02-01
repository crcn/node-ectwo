gumbo      = require "gumbo"
stepc      = require "stepc"
outcome    = require "outcome"
allRegions = require "../../utils/regions"

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

    o = outcome.e callback
    newInstanceId = null

    stepc.async () =>

      # first create a new instance
      @_ec2.call "RunInstances", { 
        "ImageId": @get("imageId"), 
        "MinCount": options.count || 1, 
        "MaxCount": options.count || 1, 
        "InstanceType": options.flavor || "m1.small" 
      }, @

      # next, refresh the servers to include the new server
      , o.s (result) =>
        newInstanceId = result.instancesSet.item.instanceId

        # load the instances to refresh the new one
        @region.instances.load @

      # finally, fetch the new instance ID object, and return it
      , o.s () =>
        @region.servers.findOne({ instanceId: newInstanceId }).exec @

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






