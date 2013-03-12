_                     = require "underscore"
gumbo                 = require "gumbo"
outcome               = require "outcome"
waitForCollectionSync = require "../../utils/waitForCollectionSync"

###
###

module.exports = class extends gumbo.Collection

  ###
  ###

  constructor: (@region, @options) ->
    @ec2 = region.ec2

    if not options.modelClass
      throw new Error "modelClass must be present"

    if not options.name
      throw new Error "options name must be present"

    

    super [], _.bind @_createModel, @
    @logger = @region.logger.child options.name
    @sync = @loader { uniqueKey: "_id", load: _.bind(@_load, @), timeout: options.timeout or 1000 * 60 }

    @_o = outcome.e @

  ###
  ###

  load: (callback) ->

    if not @_initialLoad
      @_initialLoad = true
      return @sync.start callback

    @sync.load callback

  ###
  ###

  syncAndFindOne: (options, callback) ->
    waitForCollectionSync options, @, true, _.bind(@sync.load, @sync), callback

  ###
  ###

  _createModel: (collection, item) ->
    m = new @options.modelClass collection, @region, @_transformItem item 
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
