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
      version: "2013-02-01"
    }

    # entry point to the ec2 API
    @api = aws.createEC2Client ops.key, ops.secret, { host: ops.host, version: ops.version }

    @instances      = new Instances @
    @images         = new Images @
    @keyPairs       = new KeyPairs @
    @securityGroups = new SecurityGroups @
    @addresses      = new Addresses @
    @snapshots      = new Snapshots @

  ###
  ###

  createInstance: (options, next) ->
    o = outcome.e next
    newInstanceId = null

    self = @

    stepc.async () ->

      self.api.call "RunInstances", {
        ImageId      : options.imageId,
        MinCount     : options.count or 1,
        MaxCount     : options.count or 1,
        InstanceType : options.flavor or options.type or "t1.micro"
      }, @

    , (o.s (result) ->
      newInstanceId = result.instancesSet.item.instanceId
      self.instances.wait { _id: newInstanceId }, @
    ), (o.s (instance) ->
      # TODO - add tags
      next null, instance
    ), next




module.exports = Region