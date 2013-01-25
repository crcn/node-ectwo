BaseSync = require "../../base/sync"
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

    ectwo_log.log "%s: sync images", @region.name

    callback = (()->) if not callback

    @ec2.call "DescribeImages", { "Owner.1": "self" }, (err, result) =>
      return callback() if not result.imagesSet.item

      images = if result.imagesSet.item not instanceof Array then [result.imagesSet.item] else result.imagesSet.item

      updateCollection @target.collection, images, "imageId", callback










