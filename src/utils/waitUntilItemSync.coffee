sift    = require "sift"
outcome = require "outcome"
hurryUp = require "hurryup"

###
###

module.exports = (item, search, callback) ->
    
    load = (callback) ->

      item.logger.info "wait until sync time left=#{@_timeLeft},", search

      skipIfSynced item, search, callback, outcome.e(callback).s () ->
        callback new Error "unable to meet condition #{JSON.stringify(search)} with item"


    hurryUp(load, {
      retry: true,
      timeout: 1000 * 60 * 20,
      retryTimeout: 1000 * 3
    })(callback)

###
###

module.exports.skipIfSynced = skipIfSynced = (item, search, end, next) ->
    
    stateTest = sift search

    item.reload outcome.e(end).s (result) =>
      if stateTest.test item.get()
        end()
      else
        next()