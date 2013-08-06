stepc        = require "stepc"
outcome      = require "outcome"
objectToTags = require "./objectToTags"

###
###

module.exports = (region, options, callback) ->
  
  region.logger.info "create server image=#{options.imageId}, flavor=#{options.flavor}"

  o = outcome.e callback
  newInstanceId = null

  stepc.async () ->

      
    # first create a new instance
      region.ec2.call "RunInstances", { 
        "ImageId"      : options.imageId, 
        "MinCount"     : options.count || 1, 
        "MaxCount"     : options.count || 1, 
        "InstanceType" : options.flavor || options.type || "m1.small" 
      }, @

    # next, refresh the servers to include the new server
    , (o.s (result) ->


      newInstanceId = result.instancesSet.item.instanceId

      region.logger.info "created server instance=#{newInstanceId}"

      region.instances.syncAndFindOne { _id: newInstanceId }, @
    # done
    ), (o.s (instance) ->


      tags = options.tags or { }
      tags.createdAt = Date.now()
      instance.tags.create objectToTags(tags), o.s () =>
        @ null, instance

    ), callback
