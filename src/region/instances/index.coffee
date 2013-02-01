gumbo         = require "gumbo"
InstanceModel = require "./instance"
comerr        = require "comerr"
_             = require "underscore"
flatten       = require "flatten"
outcome       = require "outcome"
stepc         = require "stepc"
findTags      = require "../../utils/findTags"
sift          = require "sift"

module.exports = class extends gumbo.Collection
	
	###
	###

	constructor: (@region) ->	
		@ec2 = region.ec2
		super [], _.bind(this._createModel, this)
		@_sync = @synchronizer { uniqueKey: "instanceId", load: _.bind(@._load, @), timeout: 1000 * 60 }

	###
	 Function: load
	###

	load: (callback) ->
		@_sync.start callback

	###
	###

	_createModel: (collection, item) ->
		item.region = @region.get "name"
		return new InstanceModel collection, @region, item

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




      


		