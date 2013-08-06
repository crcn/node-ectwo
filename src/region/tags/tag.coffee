gumbo = require "gumbo"
BaseModel = require "../base/model"

module.exports = class extends BaseModel

  ###
  ###

  constructor: (collection, item, @tags) ->
    super collection, @tags.region, item
    
  ###
  ###

  setValue: (value, callback) ->
    # @_resetTags "value", value, callback
    @update { $set: { value: value }}
    @tags.update { key: @get("key"), value: @get("value") }, callback


  ###
  ###

  _destroy: (callback) ->
    @tags._remove { key: @get("key") }, callback


  ###
  ###

  ###
  _resetTags: (property, value, callback) ->
    oldTags = @_ctags()
    update = {}
    update[property] = value
    @update({ $set: update })
    newTags  = @_ctags()
    @tags.update { key: @get("key") }, newTags, callback
  ###
    


