outcome  = require "outcome"
toarray  = require "toarray"
flatten  = require "flatten"
Instance = require "./instance"
convertTags = require "../../utils/convertTags"
stepc    = require "stepc"

class Instances extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: Instance, region: region }

  ###
  ###

  create: (options, next) ->

    o = outcome.e next
    newInstanceId = null

    self = @

    stepc.async () ->

      ops = {
        ImageId      : options.imageId,
        MinCount     : options.count or 1,
        MaxCount     : options.count or 1,
        InstanceType : options.flavor or options.type or "t1.micro"
      }

      if options.keyName
        ops.KeyName = options.keyName

      if options.securityGroupId
        ops["SecurityGroupId.1"] = options.securityGroupId

      self.region.api.call "RunInstances", ops, @

    , (o.s (result) ->
      newInstanceId = result.instancesSet.item.instanceId
      self.wait { _id: newInstanceId }, @
    ), (o.s (instances) ->
      # TODO - add tags

      instance = instances[0]

      instance.wait { state: "running" }, () ->

        if options.tags
          return instance.tag options.tags, next

        next null, instance
    ), next

  ###
  ###

  _load2: (options, next) ->

    search = {}

    if options._id
      search["InstanceId.1"] = options._id

    @region.api.call "DescribeInstances", search, outcome.e(next).s (result) =>
      instances = toarray result.reservationSet.item


      instances = flatten(instances.map((instance) ->
        instance.instancesSet.item
      )).

      # normalize the instance so it's a bit easier to handle
      map((instance) =>
        _id          : instance.instanceId,
        imageId      : instance.imageId,
        state        : instance.instanceState.name,
        dnsName      : instance.dnsName,
        type         : instance.instanceType,
        region       : @region.get("name"),
        launchTime   : new Date(instance.launchTime),
        architecture : instance.architecture,
        keyName      : instance.keyName,
        securityGroups: toarray(instance.groupSet.item).map((item) ->
          _id: item.groupId
          name: item.groupName
        ),
        tags         : convertTags(instance),
      )

      # if a specific instance needs to be reloaded, then we don't want to filter out
      # terminated instances - otherwise we may run into issues where model data never gets
      # synchronized properly
      if not options._id
        instances = instances.filter((instance) ->
          instance.state != "terminated"
        )

      next null, instances





module.exports = Instances