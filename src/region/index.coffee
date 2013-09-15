BaseModel = require "../base/model"
aws       = require "aws-lib"

Instances      = require "./instances"
Images         = require "./images"
KeyPairs       = require "./keyPairs"
SecurityGroups = require "./securityGroups"
Addresses      = require "./addresses"
SpotRequests   = require "./spotRequests"
Snapshots      = require "./snapshots"
stepc          = require "stepc"
outcome        = require "outcome"

class Region extends BaseModel

  ###
  ###

  constructor: (data, collection) ->
    super data, collection

    options = collection.ectwoOptions


    ops = {
      host: "ec2.#{@get('_id')}.amazonaws.com",
      key: options.key,
      secret: options.secret,
      version: "2013-08-15"
    }

    # entry point to the ec2 API
    @api = aws.createEC2Client ops.key, ops.secret, { host: ops.host, version: ops.version }

    @instances      = new Instances @
    @images         = new Images @
    @keyPairs       = new KeyPairs @
    @securityGroups = new SecurityGroups @
    @addresses      = new Addresses @
    @snapshots      = new Snapshots @



module.exports = Region