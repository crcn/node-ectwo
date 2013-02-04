BaseCollection = require "../base/collection"
SecurityGroup  = require "./securityGroup"
outcome        = require "outcome"

module.exports = class extends BaseCollection
  
  ###
  ###

  constructor: (region) ->
    super region, {
      uniqueKey: "groupId",
      modelClass: SecurityGroup
    }

  ###
  ###

  _load: (onLoad) ->
    @ec2.call "DescribeSecurityGroups", { }, outcome.e(onLoad).s (result) ->
      return onLoad(null, []) if not result.securityGroupInfo.item

      items = if result.securityGroupInfo.item instanceof Array then result.securityGroupInfo.item else [result.securityGroupInfo.item]

      onLoad null, items
