_       = require "underscore"
outcome = require "outcome"
hurryUp = require "hurryUp"


###
  EC2 is rather unreliable - changes are made asynchronously 
###

module.exports = (search, collection, find, reload, callback) ->
  
  load = (callback) ->
    collection.logger.info "wait for sync time left=#{@_timeLeft},", search
    reload () ->
      collection.findOne search, outcome.e(callback).s (item) ->

        retry = !!find isnt !!item

        if retry
          return callback new Error "unable to meet condition \"#{JSON.stringify(search)}\" for waitForCollectionSync"

        collection.logger.info "synchronized", search
        callback null, item


  hurryUp(load, { 
    retry: true,
    retryTimeout: 1000 * 3,
    timeout: 1000 * 60 * 20
  })(callback)
  