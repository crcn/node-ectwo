outcome = require "outcome"

class Snapshot extends require("../../base/regionModel")
  
  ###
  ###

  createVolume: (options, next) ->  

    if arguments.length is 1
      next = options
      options = {}

    options.snapshotId = @get("_id")
    @region.volumes.create options, next

  ###
  ###

  _destroy: (next) ->
    @api.call "DeleteSnapshot", { "SnapshotId.1": @get("_id") }, next
  

module.exports = Snapshot