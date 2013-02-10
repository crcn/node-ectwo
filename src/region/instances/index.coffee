gumbo          = require "gumbo"
InstanceModel  = require "./instance"
comerr         = require "comerr"
_              = require "underscore"
flatten        = require "flatten"
outcome        = require "outcome"
stepc          = require "stepc"
findTags       = require "../../utils/findTags"
sift           = require "sift"
BaseCollection = require "../base/collection"
toarray        = require "toarray"
Tags           = require "../tags"


module.exports = class extends BaseCollection
	
	###
	###

	constructor: (region) ->	
    super region, {
      modelClass: InstanceModel
    }

	###
	###

	_load: (options, onLoad) ->

    self = @
    itags = null

    search = { }

    if options._id
      search["InstanceId.1"] = options._id

    self.ec2.call "DescribeInstances", search, outcome.e(onLoad).s (result) ->
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
      ).filter((instance) ->
        instance.state != "terminated"
      )


      onLoad null, instances




      


		