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

  create: (optionsOrName, callback) ->

    if typeof optionsOrName is "string" 
      options = { name: optionsOrName }

    if not options.description
      options.description = "Security group created by node-ectwo lib"

    @ec2.call "CreateSecurityGroup", {
      GroupName: options.name,
      GroupDescription: options.description
    }, outcome.e(callback).s (result) =>
      @syncAndFindOne { groupName: options.name }, callback

  ###
  ###

  _load: (onLoad) ->
    @ec2.call "DescribeSecurityGroups", { }, outcome.e(onLoad).s (result) ->
      return onLoad(null, []) if not result.securityGroupInfo.item

      items = if result.securityGroupInfo.item instanceof Array then result.securityGroupInfo.item else [result.securityGroupInfo.item]
      
      onLoad null, items
