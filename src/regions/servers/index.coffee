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
		@sync.start callback

	###
	###

	_createModel: (collection, item) ->
		return new ServerModel collection, ec2, item