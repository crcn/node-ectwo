aws = require "aws-lib"
async = require "async"
Region = require "./region"
allRegions = require "../utils/regions"
gumbo = require "gumbo"

module.exports = class 
  
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
    @regions = gumbo.collection []
    @load()

  ###
    Function: 

    Parameters:
  ###

  load: (callback = (()->)) ->


    async.forEach @whitelist, ((regStr, next) =>
      host = "ec2.#{regStr}.amazonaws.com"
      ec2 = aws.createEC2Client @options.key, @options.secret, { host: host }
      @regions.insert(new Region(regStr, ec2).load(next)).exec next
    ), callback





