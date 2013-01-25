async = require "async"
Servers = require "./servers"
AMIs    = require "./amis"


module.exports = class 

	constructor: (@name, @ec2) ->
		@amis = new AMIs(@)
		@servers = new Servers(@)

	load: (callback) ->

		async.forEach [@amis, @servers], ((loadable, next) =>
			loadable.load next
		), callback

		@