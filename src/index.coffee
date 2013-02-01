require "./utils/logging"

aws = require "aws-lib"
async = require "async"
Region = require "./region"
allRegions = require "./utils/regions"
gumbo = require "gumbo"
JoinedRegionCollection = require "./joinedRegionCollection"
cstep = require "cstep"
outcome = require "outcome"
_ = require "underscore"




class ECTwo
  
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

    @instances = new JoinedRegionCollection @, "instances"
    @amis      = new JoinedRegionCollection @, "amis"

    # create a synchronizer, but load it only once
    @regions.synchronizer({ uniqueKey: "name", load: _.bind(@.load, @) }).load()
    @_loadRegions()
    @instances.load()
    @amis.load()

  ###
    Function: 

    Parameters:
  ###

  load: cstep (callback = (()->)) ->


    async.map @whitelist, ((regStr, next) =>

      # the API endpoint
      host = "ec2.#{regStr}.amazonaws.com"

      # create the EC2 client delegate
      ec2 = aws.createEC2Client @options.key, @options.secret, { host: host }

      next null, { name: regStr, ec2: ec2 }
    ), callback


  ###
  ###

  _createRegionModel: (collection, options) ->
    new Region collection, options

  ###
  ###

  _loadRegions: (next) ->
    async.forEach @regions.findAll().sync(), ((region, next) ->
      region.load next
    ), next


###
 returns a controller that handles are EC2 regions
###

module.exports = (options, whitelistRegions) ->
	return new ECTwo options, whitelistRegions
