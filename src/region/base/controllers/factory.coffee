sift = require "sift"

module.exports = class

  ###
  ###

  constructor: () ->
    @_classes = []
  
  ###
  ###

  addControllerClass: (search, clazz) ->
    @_classes.push {
      search: sift(search),
      clazz: clazz
    } 

  ###
  ###

  addControllers: (item) ->

    data = item.get()

    for item in @_classes
      if item.search.test data
        data.controllers.add new item.clazz item