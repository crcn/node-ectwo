Sync = require "./sync"

module.exports = class 
	
	constructor: (@region) ->
		@sync = new Sync(@)


	load: (callback) ->
		@sync.start callback
		