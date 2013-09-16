sift     = require "sift"
memoize  = require "memoize"
outcome  = require "outcome"
bindable = require "bindable"
hurryup  = require "hurryup"
comerr   = require "comerr"

class BaseCollection extends bindable.Collection

  ###
  ###

  constructor: (@options = {}) ->
    super()
    @region = @options.region
    @load = memoize @reload, { expire: false }

  ###
  ###

  waitForOne: (query, timeout, next) ->

    if arguments.length is 2
      next = timeout
      timeout = 1000 * 60 * 20

    @wait query, timeout, (err, items) ->
      return next(err) if err?
      next null, items[0]

  ###
  ###

  wait: (query, timeout, next) ->

    if arguments.length is 2
      next = timeout
      timeout = 1000 * 60 * 20

    fn = hurryup ((next) =>
      @reload () =>
        @find query, (err, items) ->
          return next(err) if err?
          return next(comerr.notFound()) unless items.length
          next(null, items)
    ), { timeout: timeout, retry: true, retryTimeout: 1000 * 5}


    fn next

  ###
  ###

  all: (cb) -> @find cb

  ###
  ###

  find: (query, next) ->

    if arguments.length is 1
      next = query
      query = () -> true

    @load { mem: true }, outcome.e(next).s (results) ->
      sifter = sift(query)

      results = results.filter (item) ->
        sifter.test item.context()

      next null, results

  ###
  ###

  toString: () ->
    @region + "." + @constructor.name.toLowerCase()

  ###
  ###

  reload: (options, next = () ->) =>  

    if arguments.length is 1
      next = options
      options = {}

    @_load2 options, outcome.e(next).s (results) =>

      existing = @source().concat()
      newItems = results.concat()


      # remove old items
      for eitem, i in existing
        found = false
        for item in newItems
          if eitem.get("_id") is item._id
            found = true
            break

        unless found
          @splice(i, 1)

      existing = @source().concat()

      # update existing items
      for item, i in newItems
        found = false
        for eitem in existing
          if eitem.get("_id") is item._id
            found = true
            results.splice(i, 1)
            eitem.reset item
            break

        #insert it
        unless found
          @push @_model item

      next null, @source()

  ###
  ###

  _model: (data) ->
    new @options.modelClass data, @


  ###
  ###

  _load2: (next) ->
    # OVERRIDE ME
    next null, []

module.exports = BaseCollection