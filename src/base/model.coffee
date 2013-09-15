bindable = require "bindable"
hurryup  = require "hurryup"
outcome  = require "outcome"
sift     = require "sift"

class BaseModel extends bindable.Object

  ###
  ###

  constructor: (data, @collection) ->
    super data 
    @region = @collection.region
    @api    = @region?.api

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
      @dispose()
      next null, @

  ###
  ###

  _destroy: (next) ->
    next()

  ###
  ###

  _load: (next) ->
    @collection.reload { _id: @get("_id") }, () -> next()

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