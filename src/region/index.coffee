_s              = require "underscore.string"
gumbo           = require "gumbo"
cstep           = require "cstep"
async           = require "async"
Images          = require "./images"
logger          = require "../utils/logger"
winston         = require "winston"
KeyPairs        = require "./keyPairs"
Instances       = require "./instances"
Addresses       = require "./addresses"
SnapShots       = require "./snapshots"
SpotRequests    = require "./spotRequests"
SecurityGroups  = require "./securityGroups"

###
Amazon doesn't have a single API to access to all regions, so we have to provide
a business delegate with a specific endpoint to the region we want to connect to. With EC2, all of them.
###

module.exports = class extends gumbo.BaseModel

  ###
  ###

  constructor: (@collection, @options, @all) ->
    super collection, { name: options.name }


    # the library entry point for API calls
    @ec2 = options.ec2

    # when logged, always prepend the region name
    @logger = logger.child("#{_s.pad(options.name, 14, ' ', 'right')}")

    # the loadable items for the particular region
    @_loadables = [
      @images         = new Images(@),
      @keyPairs       = new KeyPairs(@),
      @instances      = new Instances(@),
      @addresses      = new Addresses(@),
      @spotRequests   = new SpotRequests(@),
      @securityGroups = new SecurityGroups(@),
      @snapshots      = new SnapShots(@)
    ]


  ###
  ###

  load: cstep (callback) ->


    @logger.info "loading"

    # loop through all the loadables, and load them - don't
    # continue until everything is done
    async.forEach @_loadables, ((loadable, next) =>
      loadable.load next
    ), callback

    @

  ###
  ###

  toString: () -> @options.name