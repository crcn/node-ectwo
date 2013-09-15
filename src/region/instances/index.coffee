outcome  = require "outcome"
toarray  = require "toarray"
flatten  = require "flatten"
Instance = require "./instance"

class Instances extends require("../../base/collection")

  ###
  ###

  constructor: (@region) ->
    super { modelClass: Instance }

  ###
  ###

  _load2: (options, next) ->

    search = {}

    if options._id
      search["InstanceId.1"] = options._id

    @region.api.call "DescribeInstances", search, outcome.e(next).s (result) ->
      instances = toarray result.reservationSet.item


      instances = flatten(instances.map((instance) ->
        instance.instancesSet.item
      )).

      # normalize the instance so it's a bit easier to handle
      map((instance) ->
        _id          : instance.instanceId,
        imageId      : instance.imageId,
        state        : instance.instanceState.name,
        dnsName      : instance.dnsName,
        type         : instance.instanceType,
        launchTime   : new Date(instance.launchTime),
        architecture : instance.architecture
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