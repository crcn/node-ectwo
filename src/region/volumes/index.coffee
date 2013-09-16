Volume        = require "./volume"
outcome       = require "outcome"
toarray       = require "toarray"
utils          = require "../../utils"

class Volumes extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: Volume, region: region }


  ###
  ###

  create: (options, next) ->
    ops = utils.cleanObj {
      Size       : options.size,
      SnapshotId : options.snapshotId,
      AvailabilityZone: options.zone,
      VolumeType: options.type,
      Iops: options.iops
    }

    o = outcome.e(next)

    @api.call "CreateVolume", ops, o.s (result) =>
      @waitForOne { _id: result.volumeId }, o.s (volume) =>
        volume.wait { status: "available" }, next




  ###
  ###

  _load2: (options, next) ->

    search = {}

    o = outcome.e next

    if options._id
      search["VolumeId.1"] = options._id


    @api.call "DescribeVolumes", search, o.s (result) =>
      volumes = toarray result.volumeSet.item
      
      volumes = volumes.map (volume) ->
        _id              : volume.volumeId
        size             : volume.size
        snapshotId       : volume.snapshotId
        availabilityZone : volume.availabilityZone
        status           : volume.status
        createTime       : volume.createTime
        type             : volume.volumeType
        attachments      : toarray(volume.attachmentSet.item).map (item) ->
          instanceId          : item.instanceId
          device              : item.device
          status              : item.status
          deleteOnTermination : item.deleteOnTermination


      next null, volumes.filter (volume) ->
        volume.status isnt "deleting"




module.exports = Volumes