gumbo = require "gumbo"
BaseModel = require "../base/model"

module.exports = class extends BaseModel

  ###
  ###

  constructor: (collection, item, @tags) ->
    super collection, @tags.region, item

  ###
  ###

  setKey: (value, callback) ->
    @_resetTags "key", value, callback
    
  ###
  ###

  setValue: (value, callback) ->
    @_resetTags "value", value, callback


  ###
  ###

  _destroy: (callback) ->
    @tags.remove { key: @get("key"), value: @get("value") }, callback

  ###
   Needed incase these tags are updated - the model doesn't change
  ###

  _resetId: () ->
    @update({ $set: { "_id" : "#{@get('key')}-#{@get('value')}"}})

  ###
  ###

  _ctags: () ->
    { key: @get("key"), value: @get("value") }

  ###
  ###

  _resetTags: (property, value, callback) ->
    oldTags = @_ctags()
    update = {}
    update[property] = value
    @update({ $set: update })
    newTags  = @_ctags()
    @_resetId()
    @tags.update oldTags, newTags, callback
    


