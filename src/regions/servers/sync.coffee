_            = require "underscore"
BaseSync     = require "../../base/sync"
stepc        = require "stepc"

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
    @ec2.call "DescribeInstances", {}, (err, result) =>

      serversById = {}

      # no instances? don't do anything
      return callback() if not result.reservationSet.item

      # the shitty thing is - if there's one server, it's returned, multiple, it's an array >.>
      instances = if result.reservationSet.item not instanceof Array then [result.reservationSet.item] else result.reservationSet.item


      # fetch only the stuff we want - damn EC2 sends back a lot of junk.
      servers = instances.map (server) -> 
        server.instancesSet.item

      # fetch the ID's so we can do a lookup for all servers with these
      # image ids
      serverIds = servers.map (server) ->
        serversById[server.imageId] = server
        server.imageId

      # first find all the servers that exist 
      @target.collection.find({ imageId: { $in: [serverIds] } }).sync().forEach (item) ->
        imageId = item.get "imageId"

        # update with the new data
        item.update(serversById[imageId])

        # delete the item from the dictionary so 
        # they don't get inserted into the database
        delete serversById[imageId]


      # insert any remaining servers
      for key of serversById
        @target.collection.insert serversById[key]






