outcome = require "outcome"


class SecurityGroup extends require("../../base/regionModel")

  ###
    {
      ports: [
        {
          from: 80,
          to: 8080,
          type: "tcp",
          ranges: ["0.0.0.0/0"]
        }
      ]
    }
  ###

  authorize: (optionsOrPort, next) ->
    @_runCommand "AuthorizeSecurityGroupIngress", optionsOrPort, next

  ###
  ###

  revoke: (optionsOrPort, next) ->
    @_runCommand "RevokeSecurityGroupIngress", optionsOrPort, next

  ###
  ###

  _runCommand: (command, optionsOrPort, next) ->

    if typeof optionsOrPort == "number"
      options = { ports: [{ from: optionsOrPort, to: optionsOrPort }] }
    else
      options = optionsOrPort

    
    query = {
      GroupId: @get "_id"
    }


    for portInfo, i in options.ports
      n = i + 1

      if not portInfo.ranges
        portInfo.ranges = ["0.0.0.0/0"]

      query["IpPermissions.#{n}.IpProtocol"] = portInfo.protocol || "tcp"
      query["IpPermissions.#{n}.FromPort"] = portInfo.from or portInfo.number
      query["IpPermissions.#{n}.ToPort"] = portInfo.to or portInfo.number

      for range, j in portInfo.ranges
        query["IpPermissions.#{n}.IpRanges.#{j+1}.CidrIp"] = range


    @api.call command, query, outcome.e(next).s (result) =>
      @reload next
  
  ###
  ###

  _destroy: (next) ->
    @api.call "DeleteSecurityGroup", { GroupName: @get("name") }, next
      



module.exports = SecurityGroup