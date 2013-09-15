SecurityGroup = require "./securityGroup"
outcome       = require "outcome"
toarray       = require "toarray"

class SecurityGroups extends require("../../base/collection")

  ###
  ###

  constructor: (region) ->
    super { modelClass: SecurityGroup, region: region }


  ###
  ###

  create: (optionsOrName, next) ->

    if typeof optionsOrName is "string" 
      options = { name: optionsOrName }

    if not options.description
      options.description = "Security group"

    @region.api.call "CreateSecurityGroup", {
      GroupName: options.name,
      GroupDescription: options.description
    }, outcome.e(next).s (result) =>
      @waitForOne { name: options.name }, next


  ###
  ###

  _load2: (options, next) ->

    search = { }

    if options._id
      search["GroupId.1"] = options._id

    @region.api.call "DescribeSecurityGroups", search, outcome.e(next).s (result) ->

      items = toarray(result.securityGroupInfo.item).
      map((sg) ->
        {
          _id          : sg.groupId,
          ownerId      : sg.ownerId,
          name         : sg.groupName,
          description  : sg.groupDescription,
          permissions  : sg.ipPermissions,
        }
      )
      next null, items



module.exports = SecurityGroups