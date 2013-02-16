module.exports = class

  ###
  ###

  constructor: (@item) ->
    @_controllers = {}

  ###
   updates the controllers after the item changes
  ###

  update: () ->

  ###
  ###

  add: (controller) ->
    @_controllers[controller.name] = controller

  ###
  ###

  get: (name) ->
    @_controllers[name]

  ###
  ###

  remove: (name) ->
    delete @_controllers[name]
