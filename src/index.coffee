async   = require "async"
aws     = require "aws-lib"
Regions = require "./regions"

module.exports = (options, regions) ->
	return new Regions options, regions
