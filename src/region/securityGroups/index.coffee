toarray        = require "toarray"
SecurityGroup  = require "./securityGroup"
BaseCollection = require "../base/collection"

module.exports = class extends BaseCollection
  
  ###
  ###

  constructor: (region) ->
    super region, {
      modelClass: SecurityGroup,
      name: "securityGroup"
    }

  ###
  ###

  create: (optionsOrName, callback) ->

    if typeof optionsOrName is "string" 
      options = { name: optionsOrName }

    if not options.description
      options.description = "Security group created by node-ectwo lib"

    @ec2.call "CreateSecurityGroup", {
      GroupName: options.name,
      GroupDescription: options.description
    }, @_o.e(callback).s (result) =>
      @syncAndFindOne { name: options.name }, callback

  ###
  ###

  _load: (options, onLoad) ->

    search = { }

    if options._id
      search["GroupId.1"] = options._id

    @ec2.call "DescribeSecurityGroups", search, @_o.e(onLoad).s (result) ->

      items = toarray(result.securityGroupInfo.item).
      map((sg) ->
        {
          _id: sg.groupId,
          ownerId: sg.ownerId,
          name: sg.groupName,
          description: sg.groupDescription,
          permissions: sg.ipPermissions,
        }
      )
      onLoad null, items
