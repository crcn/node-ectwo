sift = require "sift"
outcome = require "outcome"

module.exports = (item, search, callback) ->

    checkState = () =>
      skipIfSynced item, search, callback, () ->
          setTimeout checkState, 1000 * 3

    checkState()

module.exports.skipIfSynced = skipIfSynced = (item, search, end, next) ->
    
    stateTest = sift search
    self = @

    item.reload outcome.e(end).s (result) =>
      if stateTest.test item.get()
        end()
      else
        next()