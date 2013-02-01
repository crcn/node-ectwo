async     = require "async"
Instances = require "./instances"
Images    = require "./images"
cstep     = require "cstep"
gumbo     = require "gumbo"


###
Amazon doesn't have a single API to access to all regions, so we have to provide
a business delegate with a specific endpoint to the region we want to connect to. With EC2, all of them.
###

module.exports = class extends gumbo.BaseModel

  ###
  ###

  constructor: (@collection, @options) ->
    super collection, { name: options.name }

    @ec2 = options.ec2

    # amazon machine images which are used to create servers
    @images = new Images @

    # the running / stopped servers
    @instances = new Instances @

  ###
  ###

  load: cstep (callback) ->

    ectwo_log.log "%s: loading", @get "name"

    # loop through all the loadables, and load them - don't
    # continue until everything is done
    async.forEach [@images, @instances], ((loadable, next) =>
      loadable.load next
    ), callback

    @