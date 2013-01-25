Sync = require "./sync"
gumbo = require "gumbo"
_ = require "underscore"
ImageModel = require "./ami"

module.exports = class 

	###
	###
	
	constructor: (@region) ->
		@collection = gumbo.collection [], _.bind(this._createModel, this)
		@sync = new Sync(@)

	###
	###

	load: (callback) ->
		@sync.load callback

	###
	###

	_createModel: (collection, item) ->
		item.region = @region.name
		return new ImageModel collection, @region, item
		