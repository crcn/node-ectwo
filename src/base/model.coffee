bindable = require "bindable"
hurryup  = require "hurryup"
outcome  = require "outcome"
sift     = require "sift"

class BaseModel extends bindable.Object

  ###
  ###

  constructor: (data, @collection) ->
    super data 

  ###
  ###

  reload: (next) -> @_load next


  ###
  ###

  toJSON: () -> @context()

  ###
  ###

  reset: (data) ->
    @set data

  ###
  ###

  destroy: (next) ->
    @_destroy outcome.e(next).s () =>
      @collection.reload () =>
        next null, @

  ###
  ###

  _destroy: (next) ->
    next()

  ###
  ###

  _load: (next) ->
    @collection._load2 { _id: @get("_id") }, outcome.e(next).s (results) =>
      @reset results[0]
      next null, @

  ###
  ###

  skip: (properties, skip, load) ->
    return skip(null, @) if @synced(properties)
    load()
    
  ###
  ###

  synced: (properties) ->
    return sift(properties).test @context()

  ###
  ###

  wait: (properties, next) ->

    load = (next) =>

      @reload outcome.e(next).s () =>

        unless @synced(properties)
          return next(new Error("unable to sync properties"))

        next null, @


    fn = hurryup load, {
      retry: true,
      timeout: 1000 * 60 * 20,
      retryTimeout: 1000 * 3
    }

    fn next


module.exports = BaseModel