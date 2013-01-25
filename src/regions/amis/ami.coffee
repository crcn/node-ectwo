gumbo = require "gumbo"
stepc = require "stepc"
outcome = require "outcome"

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

	createServer: (options, callback) ->
    o = outcome.e callback
    newInstanceId = null

    stepc () =>

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
        @region.servers.load @

      # finally, fetch the new instance ID object, and return it
      , o.s () =>
        @region.servers.findOne({ instanceId: newInstanceId }).exec @

  ###
    Function: removes the AMI 

    Parameters:
  ###

  deRegister: (callback) ->
    @_ec2.call "DeregisterImage", { "ImageId": @get("imageId") }, callback






