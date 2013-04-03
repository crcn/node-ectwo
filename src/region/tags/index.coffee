_                     = require "underscore"
Tag                   = require "./tag"
gumbo                 = require "gumbo"
toarray               = require "toarray"
tagsToObject          = require "../../utils/tagsToObject"
waitForCollectionSync = require "../../utils/waitForCollectionSync"
outcome = require "outcome"
async = require "async"


###
###

module.exports = class

  ###
  ###

  constructor: (@item) ->

    @_ec2 = item._ec2
    @region = item.region
    @_collection = new gumbo.Collection [], _.bind(@_createTag, @)
    @logger = @_collection.logger = @item.logger.child "tags"
    @_sync = @_collection.loader { uniqueKey: "_id", load: _.bind(@_loadTags, @), timeout: false }
    @_sync.load()

  ###
  ###

  find: () -> @_collection.find.apply @_collection, arguments

  ###
  ###

  findOne: () -> @_collection.findOne.apply @_collection, arguments

  ###
  ###

  create: (tags, callback, reload) ->
    @logger.info "create", tags
    @_call tags, "CreateTags", reload isnt false, () =>
      @logger.info "created", tags
      callback.apply this, arguments

  ###
  ###

  toObject: () -> tagsToObject @item.get("tags")

  ###
  ###

  getKeyValue: (key) -> @toObject()[key]

  ###
  ###

  remove: (tags, callback, reload) ->
    o = outcome.e callback
    @find tags, o.s (tags) =>
      async.forEachSeries tags, ((tag, next) ->
        tag.destroy next
      ), () =>
        return callback if reload is false
        @_reload callback


  ###
  ###

  update: (oldTags, newTags, callback) ->
    @_remove(oldTags, (() =>
      @create newTags, callback, true
    ), false)

  ###
  ###

  _remove: (tags, callback, reload) ->
    @_call tags, "DeleteTags", reload isnt false, callback

  ###
  ###

  _call: (tags, command, reload, callback) ->

    self = this
    tags = toarray tags
    data = @_prepareQuery tags

    tagIds = tags.map (tag) -> "#{tag.key}-#{tag.value}"

    search = {}

    search._id = { $in: tagIds }
    neg = not /DeleteTags/.test command


    load = (callback) =>
      @_ec2.call command, JSON.parse(JSON.stringify(data)), outcome.e(callback).s (result) =>
        return callback() if not reload
        @_reload callback


    return load(callback) if not reload


    # need to call add / remove key multiple times - sometimes it
    # doesn't work immediately 
    waitForCollectionSync search, self._collection, neg, load, callback

  ###
  ###

  _reload: (callback = (()->)) ->
    @item.reload outcome.e(callback).s () =>
      @_sync.load callback

  ###
  ###

  _prepareQuery: (tags) ->

    toUpdate = {
      "ResourceId.1": @item.get "_id"
    }

    for tag, i in tags
      toUpdate["Tag.#{i+1}.Key"]   = tag.key
      toUpdate["Tag.#{i+1}.Value"] = tag.value

    toUpdate

  ###
  ###

  _createTag: (collection, item) ->
    new Tag collection, item, @

  ###
  ###

  _loadTags: (options, callback)  ->

    callback null, @item.get "tags"

###
###

module.exports.transformTags = (rawData) ->
  toarray(rawData.tagSet?.item).
  map((tag) ->
    {
      _id   : "#{tag.key}-#{tag.value}",
      key   : tag.key,
      value : tag.value
    }
  )
