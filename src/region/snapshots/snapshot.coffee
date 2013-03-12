gumbo       = require "gumbo"
async       = require "async"
toarray     = require "toarray"
winston     = require "winston"
BaseModel   = require "../base/model"

###
###

module.exports = class extends BaseModel

  ###
  ###

  registerImage: (options, callback) ->

    if arguments.length == 1
      callback = options
      options = {}

    @logger.info "register image"

    deviceName = "/dev/sda1"

    ops = {
      "RootDeviceName": deviceName,
      "BlockDeviceMapping.1.DeviceName": deviceName,
      "BlockDeviceMapping.1.Ebs.SnapshotId": @get("_id"),
      "Name": @get("image.name") or String(Date.now())
    }

    if options.architecture
      ops["Architecture"] = options.architecture

    @_ec2.call "RegisterImage", ops, @_o.e(callback).s (result) =>
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

    @logger.info "destroy"

    @_ec2.call "DeleteSnapshot", { "SnapshotId.1": @get("_id") }, @_o.e(callback).s () =>
      callback()

