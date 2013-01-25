gumbo       = require "gumbo"
ServerModel = require "./server"
Sync        = require "./sync"
comerr      = require "comerr"
_ = require "underscore"

module.exports = class
	
	###
	###

	constructor: (@region) ->	

		@collection = gumbo.collection [], _.bind(this._createModel, this)

		@sync = new Sync @

	###
	 Function: load
	###

	load: (callback) ->
		@sync.load callback

	###
	###

	_createModel: (collection, item) ->
		item.region = @region.name
		return new ServerModel collection, @region, item