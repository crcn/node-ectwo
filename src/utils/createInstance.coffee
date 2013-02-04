stepc   = require "stepc"
outcome = require "outcome"


module.exports = (region, options, callback) ->

  ectwo_log.log "%s: create server", region.name

  o = outcome.e callback
  newInstanceId = null

  stepc.async () ->

    # first create a new instance
      @_ec2.call "RunInstances", { 
        "ImageId"      : options.imageId, 
        "MinCount"     : options.count || 1, 
        "MaxCount"     : options.count || 1, 
        "InstanceType" : options.flavor || "m1.small" 
      }, @

    # next, refresh the servers to include the new server
    , (o.s (result) ->
      newInstanceId = result.instancesSet.item.instanceId

      # load the instances to refresh the new one
      region.instances.load @

    # finally, fetch the new instance ID object, and return it
    ), (o.s () ->
      region.servers.findOne({ instanceId: newInstanceId }).exec @

    # done
    ), callback