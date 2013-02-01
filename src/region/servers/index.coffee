gumbo       = require "gumbo"
ServerModel = require "./server"
comerr      = require "comerr"
_ = require "underscore"

module.exports = class extends gumbo.Collection
	
	###
	###

	constructor: (@region) ->	
		@ec2 = region.ec2
		super [], _.bind(this._createModel, this)
		@_sync = @synchronizer { uniqueKey: "instanceId", load: _.bind(@._load, @), timeout: 1000 }

	###
	 Function: load
	###

	load: (callback) ->
		@_sync.start callback

	###
	###

	_createModel: (collection, item) ->
		item.region = @region.get "name"
		return new ServerModel collection, @region, item

	###
	###

	_load: (onLoad) ->

		@ec2.call "DescribeInstances", {}, (err, result) =>

      serversById = { }

      # no instances? don't do anything
      return onLoad(null, []) if not result.reservationSet.item

      # the shitty thing is - if there's one server, it's returned, multiple, it's an array >.>
      instances = if result.reservationSet.item not instanceof Array then [result.reservationSet.item] else result.reservationSet.item

      instances = instances.map (instance) ->
      	return instance.instancesSet.item


      onLoad null, instances