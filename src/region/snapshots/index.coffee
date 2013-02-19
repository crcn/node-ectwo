BaseCollection = require "../base/collection"
outcome        = require "outcome"
toarray        = require "toarray"
SnapShot       = require "./snapshot"

module.exports = class extends BaseCollection
  
  ###
  ###

  constructor: (region) ->
    super region, {
      modelClass: SnapShot,
      timeout: 1000 * 60 * 60
    }

  ###
   Copies a snapshot from a particular region. This is a PULL.
  ###

  copy: (options, callback) ->

    @ec2.call "CopySnapshot", {
      "SourceRegion": options.region,
      "SourceSnapshotId": options._id,
      "Description": options.description
    }, outcome.e(callback).s (result) =>
      console.log result
      @syncAndFindOne { _id: result.snapshotId }, callback

  

  ###
  ###

  _load: (options, onLoad) ->

    search = { "Owner.1": "self" }
    # search = {}

    if options._id
      search["SnapshotId.1"] = options._id

    @ec2.call "DescribeSnapshots", search, outcome.e(onLoad).s (result) ->

      snapshots = toarray(result.snapshotSet.item).
      map((item) ->

        console.log item.snapshotId
        console.log search

        volInfo = parseDescription item

        {
          _id: item.snapshotId,
          volumneId: item.volumeId,
          status: item.status,
          startedAt: new Date(item.startTime),
          progress: Number(item.progress.substr(0, item.progress.length - 1)) / 100,
          ownerId: item.ownerId,
          volumeSize: item.volumeSize,
          description: if typeof item.description is "object" then "" else item.description,

          # stuff pulled from the description of the snapshot
          instanceId: volInfo.instanceId,
          volumeId: volInfo.volumeId,
          imageId: volInfo.imageId,

          # used if called .migrate() from image
          image: volInfo.image
        }
      )


      onLoad null, snapshots



parseDescription = (item) ->
    
  # description might be a JSON 
  try 
    return JSON.parse item.description
  catch e


  if ~item.description.indexOf "CreateImage"
    return parseCreateImageDescription item

  return {}
  
###
 Jesus this is fugly, but EC2 unfortunately doesn't offer the ability to find the associated volumes / instances / ami's
 with each spot 
###

parseCreateImageDescription = (item) ->
  # Created by CreateImage(i-f06f9483) for ami-040b9b6d from vol-bf361bce
  match = item.description.match(/CreateImage\((.+?)\) for (.+?) from (.*)/)
  return {} if not match

  return { instanceId: match[1], imageId: match[2], volumeId: match[3] }
  # return "Created by CreateImage(i-f06f9483) for ami-040b9b6d from vol-bf361bce"

      
    
