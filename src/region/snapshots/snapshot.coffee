gumbo = require "gumbo"
BaseModel = require "../base/model"
outcome    = require "outcome"
async = require "async"
toarray = require "toarray"

module.exports = class extends BaseModel

  ###
  ###

  registerImage: (options, callback) ->

    if arguments.length == 1
      callback = options
      options = {}

    deviceName = "/dev/sda1"

    @_ec2.call "RegisterImage", {
      "RootDeviceName": deviceName,
      "BlockDeviceMapping.1.DeviceName": deviceName,
      "BlockDeviceMapping.1.Ebs.SnapshotId": @get("_id"),
      "Name": @get("image.name") or String(Date.now())
    }, outcome.e(callback).s (result) =>
      @region.images.syncAndFindOne { _id: result.imageId }, callback

  ###
   Migrates the snapshot to another region - this is a mush
  ###

  migrate: (regions, callback) ->
    async.forEach(toarray(regions), ((region, next) =>
      region.snapshots.copy {
        _id: @get("_id"),
        region: @get("region"),
        description: @get("description")
      }, next
    ), callback)
  
  ###
  ###

  _destroy: (callback) ->
    @_ec2.call "DeleteSnapshot", { "SnapshotId.1": @get("_id") }, outcome.e(callback).s () =>
      callback()
