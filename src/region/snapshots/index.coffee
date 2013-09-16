outcome  = require "outcome"
Snapshot = require "./snapshot"
toarray  = require "toarray"
utils    = require "../../utils"

class Snapshots extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: Snapshot, region: region }

  ###
  ###

  create: (volumeId, description, next) -> 

    if arguments.length is 2
      next = description
      description = undefined

    o = outcome.e(next)

    @api.call "CreateSnapshot", utils.cleanObj({
      VolumeId: volumeId,
      Description: description
    }), o.s (result) =>
      @waitForOne { _id: result.snapshotId }, next


  ###
  ###

  _load2: (options, next) ->

    search = { "Owner.1": "self" }
    # search = {}

    if options._id
      search["SnapshotId.1"] = options._id


    o = outcome.e(next)

    @api.call "DescribeSnapshots", search, o.s (result) =>

      snapshots = toarray(result.snapshotSet.item).
      map((item) =>

        volInfo = parseDescription item

        {
          _id: item.snapshotId,
          volumneId: item.volumeId,
          status: item.status,
          startedAt: new Date(item.startTime),

          # remove the % sign
          progress: Number(item.progress.substr(0, item.progress.length - 1)),
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

      next null, snapshots



parseDescription = (item) ->

  desc = String(item.description)
    
  # description might be a JSON 
  try 
    return JSON.parse desc
  catch e


  if ~desc.indexOf "CreateImage"
    return parseCreateImageDescription desc

  return {}
  
###
 Jesus this is fugly, but EC2 unfortunately doesn't offer the ability to find the associated volumes / instances / ami's
 with each spot 
###

parseCreateImageDescription = (desc) ->
  # Created by CreateImage(i-f06f9483) for ami-040b9b6d from vol-bf361bce
  match = desc.match(/CreateImage\((.+?)\) for (.+?) from (.*)/)
  return {} if not match

  return { instanceId: match[1], imageId: match[2], volumeId: match[3] }
  # return "Created by CreateImage(i-f06f9483) for ami-040b9b6d from vol-bf361bce"


module.exports = Snapshots