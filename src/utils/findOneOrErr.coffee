outcome = require "outcome"
module.exports = (collection, search, callback) ->
  collection.findOne search, outcome.e(callback).s (result) ->
    return new Error "Unable to find one with query=#{JSON.stringify(search)}" if not result
    callback null, result