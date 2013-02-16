gumbo = require "gumbo"
_ = require "underscore"
waitForCollectionSync = require "../../utils/waitForCollectionSync"
ControllerFactory = require "./controllers/factory"

module.exports = class extends gumbo.Collection

  ###
  ###

  constructor: (@region, @options) ->
    @ec2 = region.ec2

    if not options.modelClass
      throw new Error "modelClass must be present"

    super [], _.bind @_createModel, @
    @sync = @synchronizer { uniqueKey: "_id", load: _.bind(@_load, @), timeout: options.timeout or 1000 * 60 }
    @controllerFactory = new ControllerFactory()

  ###
  ###

  load: (callback) ->

    if not @_initialLoad
      @_initialLoad = true
      return @sync.start callback

    @sync.load callback

  ###
  ###

  addControllerClass: (search, controller) ->
    @controllerFactory.addControllerClass(search, controller)

  ###
  ###

  syncAndFindOne: (options, callback) ->
    waitForCollectionSync options, @, true, _.bind(@sync.load, @sync), callback

  ###
  ###

  _createModel: (collection, item) ->
    m = new @options.modelClass collection, @region, @_transformItem item 
    @controllerFactory.addControllers m
    m

  ###
  ###

  _load: (onLoad) ->
    throw new Error "must be overridden"

  ###
  ###

  _transformItem: (item) -> 
    item.region = @region.get "name"
    item

  ###
  ###

  _load: () ->
