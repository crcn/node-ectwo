gumbo = require "gumbo"
BaseModel = require "../base/model"
outcome = require "outcome"

module.exports = class extends BaseModel

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

  authorizePorts: (optionsOrPort, callback) ->

    if typeof optionsOrPort == "number"
      options = { ports: [{ from: optionsOrPort, to: optionsOrPort }] }
    else
      options = optionsOrPort

    
    query = {
      GroupId: @get "_id"
    }


    for portInfo, i in options.ports
      n = i+1

      if not portInfo.ranges
        portInfo.ranges = ["0.0.0.0/0"]

      query["IpPermissions.#{n}.IpProtocol"] = portInfo.protocol || "tcp"
      query["IpPermissions.#{n}.FromPort"] = portInfo.from or portInfo.number
      query["IpPermissions.#{n}.ToPort"] = portInfo.to or portInfo.number

      for range, j in portInfo.ranges
        query["IpPermissions.#{n}.IpRanges.#{j+1}.CidrIp"] = range


    @_ec2.call "AuthorizeSecurityGroupIngress", query, outcome.e(callback).s (result) ->
      callback null, result

  ###
   destroys the keypair
  ###


  destroy: (callback) ->
    @_ec2.call "DeleteSecurityGroup", { GroupName: @get "name" }, outcome.e(callback).s () =>
      @collection.load callback