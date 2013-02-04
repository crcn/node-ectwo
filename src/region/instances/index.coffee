gumbo         = require "gumbo"
InstanceModel = require "./instance"
comerr        = require "comerr"
_             = require "underscore"
flatten       = require "flatten"
outcome       = require "outcome"
stepc         = require "stepc"
findTags      = require "../../utils/findTags"
sift          = require "sift"
BaseCollection = require "../base/collection"

module.exports = class extends BaseCollection
	
	###
	###

	constructor: (region) ->	
    super region, {
      uniqueKey: "instanceId",
      modelClass: InstanceModel
    }

	###
	###

	_load: (onLoad) ->

    self = @
    o = outcome.e onLoad
    itags = null

    self.ec2.call "DescribeInstances", { }, o.s (result) ->
      serversById = { }

      # no instances? don't do anything
      return onLoad(null, []) if not result.reservationSet.item

      # the shitty thing is - if there's one server, it's returned, multiple, it's an array >.>
      instances = if result.reservationSet.item not instanceof Array then [result.reservationSet.item] else result.reservationSet.item

      instances = instances.map (instance) ->
        return instance.instancesSet.item

      instances = flatten instances

      # ignore all terminated instances
      instances = instances.filter (instance) ->
        return instance.instanceState.name != "terminated"



      onLoad null, instances




      


		