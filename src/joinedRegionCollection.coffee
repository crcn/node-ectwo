async   = require "async"
cstep   = require "cstep"
outcome = require "outcome"
flatten = require "flatten"


class ControllerFactory
  
  ###
  ###

  constructor: (@joinedCollection) ->
    cstep(@).add joinedCollection

  ###
  ###

  addControllerClass: cstep (search, clazz, next) ->

    for region in @joinedCollection._regions()
      region[@joinedCollection.collectionType].controllerFactory.addControllerClass(search, clazz)

    next()




module.exports = class
    
  ###
    Function: 

    Parameters:
  ###

  constructor: (@ectwo, @collectionType) ->


  ###
    Function: 

    Parameters:
  ###

  load: () ->
    cstep(@).add @ectwo
    @controllerFactory = new ControllerFactory @

  ###
  ###

  addControllerClass: (search, controller) ->
    @controllerFactory.addController(search, controller)


  ###
  ###

  watch: cstep (query, observers, next) ->
    for region in @_regions()
      region.watch query, observers

    next()

  ###
    Function: 

    searches through ALL the data centers for servers with the given query

    Parameters:
  ###

  find: cstep (query, callback) ->
    async.map @_regions(), ((region, next) =>
      region[@collectionType].find(query).exec next
    ), outcome.e(callback).s (results) ->
      callback null, flatten results
      
  ###
  ###

  findOneFromEach: cstep (query, callback) ->
    async.map @_regions(), ((region, next) =>
      region[@collectionType].findOne(query).exec next
    ), outcome.e(callback).s (results) ->
      callback null, flatten results


  ###
    Function: 

    Parameters:
  ###

  findOne: cstep (query, callback) ->

    calledBack = false

    onItem = (item) ->
      return if calledBack
      calledBack = true
      callback null, item

    async.forEach @_regions(), ((region, next) =>
      region[@collectionType].findOne(query).exec (err, item) ->
        if item
          onItem(item)
        next()
    ), () ->
      onItem null


  ###
  ###

  findAll: (callback) ->
    @find (() -> true), callback


  ###
    Function: 

    Parameters:
  ###

  _regions: () -> @ectwo.regions.findAll().sync()





