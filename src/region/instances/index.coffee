outcome  = require "outcome"
toarray  = require "toarray"
flatten  = require "flatten"
Instance = require "./instance"
type     = require "type-component"
convertTags = require "../../utils/convertTags"
stepc    = require "stepc"
utils    = require "../../utils"
async    = require "async"

class Instances extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: Instance, region: region }

  ###
  ###

  create: (options, next) ->


    if type(options) is "number"
      options = { count: options }

    o = outcome.e next
    newInstanceId = null

    self = @

    stepc.async () ->

      if options.volumeSize and not options.deviceName
        options.deviceName = "/dev/sda1"


      ops = utils.cleanObj {
        ImageId             : options.imageId,
        MinCount            : options.count or 1,
        MaxCount            : options.count or 1,
        KeyName             : options.keyName
        "SecurityGroupId.1" : options.securityGroupId,
        "BlockDeviceMapping.1.DeviceName": options.deviceName,
        "BlockDeviceMapping.1.Ebs.VolumeSize": options.volumeSize,
        "BlockDeviceMapping.1.Ebs.VolumeType": options.volumeType,
        InstanceType        : options.flavor or options.type or "t1.micro"
      }

      self.region.api.call "RunInstances", ops, @

    , (o.s (result) ->
      newInstanceIds = toarray(result.instancesSet.item).map (item) ->

        item.instanceId

      # go through each ID, and wait for the instance to appear in this
      # collection
      async.each newInstanceIds, ((instanceId, next) ->
        self.wait { _id: String(instanceId) }, next
      ), o.s () =>

        # find the new instances
        self.find { _id: {$in: newInstanceIds }}, @

    ), (o.s (instances) ->

      # go through each instance, and wait for the state to change
      # from pending to running
      async.each instances, ((instance, next) ->

        instance.wait { state: "running" }, () ->

          # after the instance is ready, tag it.
          if options.tags
            return instance.tag options.tags, next

          next null, instance
      ), o.s () =>

        if instances.length is 1
          return @ null, instances[0]

        @ null, instances

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
        address      : instance.ipAddress,
        securityGroups: toarray(instance.groupSet.item).map((item) ->
          _id: item.groupId
          name: item.groupName
        ),
        tags         : convertTags(instance)
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