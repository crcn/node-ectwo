sift = require "sift"
outcome = require "outcome"

module.exports = (item, search, callback) ->
    
    tries = 100

    checkState = () =>
      tries--
      skipIfSynced item, search, callback, outcome.e(callback).s () ->
          if not tries
            callback new Error("unable to meet condition #{JSON.stringify(search)} with item")

          setTimeout checkState, 1000 * 3

    checkState()

module.exports.skipIfSynced = skipIfSynced = (item, search, end, next) ->
    
    stateTest = sift search

    item.reload outcome.e(end).s (result) =>
      if stateTest.test item.get()
        end()
      else
        next()