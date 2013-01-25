aws = require "aws-lib"
async = require "async"
Region = require "./region"

module.exports = class 
	

	constructor: (@options, @whitelist = ["us-west-1", "us-west-2", "us-east-1", "eu-west-1", "sa-east-1", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1"]) ->
		@load()

	load: (callback = (()->)) ->

		@regions = []

		async.forEach @whitelist, ((regStr, next) =>
			host = "ec2.#{regStr}.amazonaws.com"
			ec2 = aws.createEC2Client @options.key, @options.secret, { host: host }
			@regions.push new Region(regStr, ec2).load(next)
		), callback




