BaseSync = require "../../base/sync"

module.exports = class extends BaseSync
  

  ###
    Function: updates 

    Updates the collection with the newest server info from EC2.
    Note - this is really only important for inserting NEW ec2 instances, since
    each server does a fetch for new information periodically

    Parameters:
  ###

  update: (callback) ->
    callback = (()->) if not callback
    @ec2.call "DescribeImages", { "Owner.1": "self" }, (err, result) =>
      # console.log result.imagesSet.item







