_ = require "underscore"
outcome = require "outcome"


###
  EC2 is rather unreliable - changes are made asynchronously 
###

module.exports = (search, collection, find, reload, callback, tries = 100) ->
  
  reload () ->

    collection.findOne search, outcome.e(callback).s (item) ->

      retry = !!find isnt !!item

      if retry 
        # console.log tries
        if not tries
          return callback new Error "unable to meet condition \"#{JSON.stringify(search)}\" for waitForCollectionSync"
        return setTimeout _.bind(module.exports, module, search, collection, find, reload, callback, tries-1), 1000

      callback null, item