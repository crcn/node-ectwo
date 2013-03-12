outcome = require "outcome"

###
###

module.exports = (ec2, type, callback) ->
  
  ec2.call "DescribeTags", {"Filter.1.Name":"resource-type", "Filter.1.Value.1": type }, outcome.e(callback).s (result) ->
    return callback(null, []) if not result.tagSet.item

    tags = if result.tagSet.item instanceof Array then result.tagSet.item else [result.tagSet.item]

    callback null, tags
