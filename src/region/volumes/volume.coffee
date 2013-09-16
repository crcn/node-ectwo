outcome = require "outcome"

class Volume extends require("../../base/regionModel")
  
  ###
  ###

  attach: (instanceId, device, next) ->

    if arguments.length is 2
      next = device
      device = "/dev/sdh"

    @api.call "AttachVolume", {
      VolumeId: @get("_id"),
      InstanceId: instanceId,
      Device: device
    }, outcome.e(next).s () => 
      @region.instances.reload () => @reload next

  ###
  ###

  createSnapshot: (description, next) ->

    if arguments.length is 1
      next = description
      description = undefined

    @region.snapshots.create @get("_id"), description, next

  ###
  ###

  detach: (next) ->
    @api.call "DetachVolume", {
      VolumeId: @get("_id")
    }, outcome.e(next).s () => 
      @region.instances.reload () => @reload next

  ###
  ###

  _destroy: (next) ->
    @api.call "DeleteVolume", {
      VolumeId: @get("_id")
    }, outcome.e(next).s () => @reload next
  

module.exports = Volume