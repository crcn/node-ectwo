stepc   = require "stepc"
outcome = require "outcome"
objectToTags = require "./objectToTags"
tagsToObject = require "./tagsToObject"


module.exports = (region, options, callback) ->

  ectwo_log.log "%s: create server", region.name

  o = outcome.e callback
  newInstanceId = null

  stepc.async () ->

    # first create a new instance
      region.ec2.call "RunInstances", { 
        "ImageId"      : options.imageId, 
        "MinCount"     : options.count || 1, 
        "MaxCount"     : options.count || 1, 
        "InstanceType" : options.flavor || "m1.small" 
      }, @

    # next, refresh the servers to include the new server
    , (o.s (result) ->
      newInstanceId = result.instancesSet.item.instanceId

      region.instances.syncAndFindOne { _id: newInstanceId }, @

    # done
    ), (o.s (instance) ->

      tags = options.tags or { }
      tags.createdAt = Date.now()
      instance.tags.create objectToTags(tags), o.s () =>
        @ null, instance
    ), callback
