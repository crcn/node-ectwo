_                      = require "underscore"
aws                    = require "aws-lib"
async                  = require "async"
gumbo                  = require "gumbo"
cstep                  = require "cstep"
Region                 = require "./region"
outcome                = require "outcome"
winston                = require "winston"
allRegions             = require "./utils/regions"
EventEmitter           = require("events").EventEmitter
JoinedRegionCollection = require "./joinedRegionCollection"

###
###

winston.remove(winston.transports.Console);
winston.add(winston.transports.Console, { silent: !process.env.LOG_ECTWO });
outcome.logAllErrors(!!process.env.LOG_ECTWO)

###
###

class ECTwo extends EventEmitter
  
  ###
    Function: Constructor

    Parameters:
      options
        key - the EC2 key
        secret - the EC2 private key
      whitelist The whitelist of ec2 regions we want to deploy servers to
  ###

  constructor: (@options, whitelist) ->
    @whitelist = if whitelist then whitelist else allRegions

    # ALL the regions in the world
    @regions   = gumbo.collection [], _.bind(this._createRegionModel, this)


    for collectionName in ["instances", "images", "keyPairs", "securityGroups", "addresses", "spotRequests", "snapshots"]
      @[collectionName] = new JoinedRegionCollection @, collectionName

    @_o = outcome.e @

    # create a synchronizer, but load it only once
    @regions.loader({ load: _.bind(@.load, @) }).load()
    @_loadRegions()
    @instances.load()
    @images.load()

  ###
    Function: 

    Parameters:
  ###

  load: cstep (callback) ->

    callback null, @whitelist.map (regStr) =>
      # the API endpoint
      host = "ec2.#{regStr}.amazonaws.com"

      # create the EC2 client delegate
      ec2 = aws.createEC2Client @options.key, @options.secret, { host: host, version: "2013-02-01" }

      { name: regStr, ec2: ec2, _id: regStr }

  ###
  ###

  _createRegionModel: (collection, options) ->
    new Region collection, options, @

  ###
  ###

  _loadRegions: (next) ->
    @regions.findAll @_o.e(next).s (regions) =>
      async.forEach regions, ((region, next) ->
        region.load next
      ), next


###
 returns a controller that handles are EC2 regions
###

module.exports = (options, whitelistRegions) ->
	return new ECTwo options, whitelistRegions or options.regions

###
###

module.exports.utils = {
  objectToTags: require("./utils/objectToTags")
}

###
 Expose all regions within ECTwo
###

module.exports.regions = allRegions
module.exports.utils = require "./utils"

###
 Plugin.js hooks
###

module.exports.plugin = (loader) ->

  awsConfig = loader.params("aws")

  return new ECTwo({
    key: awsConfig.key,
    secret: awsConfig.secret
  }, awsConfig.regions)
