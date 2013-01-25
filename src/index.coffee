async   = require "async"
aws     = require "aws-lib"
Regions = require "./regions"
require "./utils/logging"

module.exports = (options, regions) ->
	return new Regions options, regions
