_              = require "underscore"
Tags           = require "../tags"
gumbo          = require "gumbo"
stepc          = require "stepc"
comerr         = require "comerr"
flatten        = require "flatten"
toarray        = require "toarray"
findTags       = require "../../utils/findTags"
InstanceModel  = require "./instance"
BaseCollection = require "../base/collection"

###
###

module.exports = class extends BaseCollection
	
	###
	###

	constructor: (region) ->	
    super region, {
      modelClass: InstanceModel,
      name: "instance"
    }

	###
	###

	_load: (options, onLoad) ->

    self = @
    itags = null

    search = { }

    if options._id
      search["InstanceId.1"] = options._id

    self.ec2.call "DescribeInstances", search, @_o.e(onLoad).s (result) ->
      serversById = { }

      # the shitty thing is - if there's one server, it's returned, multiple, it's an array >.>
      instances = toarray result.reservationSet.item

      instances = flatten(instances.map((instance) ->
        instance.instancesSet.item
      )).

      # normalize the instance so it's a bit easier to handle
      map((instance) ->
        {
          _id: instance.instanceId,
          imageId: instance.imageId,
          state: instance.instanceState.name,
          dnsName: instance.dnsName,
          type: instance.instanceType,
          launchTime: new Date(instance.launchTime),
          architecture: instance.architecture,
          tags: Tags.transformTags instance
        }
      )


      # if a specific instance needs to be reloaded, then we don't want to filter out
      # terminated instances - otherwise we may run into issues where model data never gets
      # synchronized properly
      if not options._id
        instances = instances.filter((instance) ->
          instance.state != "terminated"
        )

      onLoad null, instances




      


		