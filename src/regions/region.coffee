async = require "async"
Servers = require "./servers"
AMIs    = require "./amis"


###
Amazon doesn't have a single API to access to all regions, so we have to provide
a business delegate with a specific endpoint to the region we want to connect to. With EC2, all of them.
###

module.exports = class 

	constructor: (@name, @ec2) ->

		# amazon machine images which are used to create servers
		@amis = new AMIs(@)

		# the running / stopped servers
		@servers = new Servers(@)

	load: (callback) ->

		ectwo_log.log "%s: loading", @name

		# loop through all the loadables, and load them - don't
		# continue until everything is done
		async.forEach [@amis, @servers], ((loadable, next) =>
			loadable.load next
		), callback

		@