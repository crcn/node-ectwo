gumbo           = require "gumbo"
cstep           = require "cstep"
async           = require "async"
Images          = require "./images"
KeyPairs        = require "./keyPairs"
Instances       = require "./instances"
Addresses       = require "./addresses"
SecurityGroups  = require "./securityGroups"

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

    @_loadables = [
      @images         = new Images(@),
      @keyPairs       = new KeyPairs(@),
      @instances      = new Instances(@),
      @addresses      = new Addresses(@),
      @securityGroups = new SecurityGroups(@)
    ]


  ###
  ###

  load: cstep (callback) ->

    ectwo_log.log "%s: loading", @get "name"


    # loop through all the loadables, and load them - don't
    # continue until everything is done
    async.forEach @_loadables, ((loadable, next) =>
      loadable.load next
    ), callback

    @