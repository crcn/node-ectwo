_            = require "underscore"
BaseSync     = require "../../base/sync"
stepc        = require "stepc"
updateCollection = require "../../utils/updateCollection"

module.exports = class extends BaseSync

  ###
    Function: updates 

    Updates the collection with the newest server info from EC2.
    Note - this is really only important for inserting NEW ec2 instances, since
    each server does a fetch for new information periodically

    Parameters:
  ###

  update2: (callback) ->

    ectwo_log.log "%s: sync servers", @region.name

    callback = (()->) if not callback
    @ec2.call "DescribeInstances", {}, (err, result) =>

      serversById = { }

      # no instances? don't do anything
      return callback() if not result.reservationSet.item

      # the shitty thing is - if there's one server, it's returned, multiple, it's an array >.>
      instances = if result.reservationSet.item not instanceof Array then [result.reservationSet.item] else result.reservationSet.item

      updateCollection @target.collection, instances, "instanceId", callback






