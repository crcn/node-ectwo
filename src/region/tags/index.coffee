gumbo = require "gumbo"
toarray = require "toarray"
Tag = require "./tag"
_ = require "underscore"
toarray = require "toarray"
waitForCollectionSync = require "../../utils/waitForCollectionSync"


###
###

module.exports = class

  ###
  ###

  constructor: (@item) ->

    @_ec2 = item._ec2
    @_collection = new gumbo.Collection [], _.bind(@_createTag, @)
    @_sync = @_collection.synchronizer { uniqueKey: "_id", load: _.bind(@_loadTags, @), timeout: false }
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
    @_call tags, "CreateTags", reload isnt false, callback


  ###
  ###

  remove: (tags, callback, reload) ->
    @_call tags, "DeleteTags", reload isnt false, callback

  ###
  ###

  update: (tags, callback) ->
    @remove(tags, (() =>
      @create tags, callback
    ), false)


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

  _reload: (callback) ->
    #@_ec2.call "DescribeTags", { "Filter.1.Name": "resource-id", "Filter.1.Value.1": @item.get "_id" }, () ->
    #  console.log arguments[1]

    ###
    @_ec2.call "DescribeInstances", {"InstanceId.1": @item.get "_id" }, (err, result) ->
        console.log JSON.stringify result.reservationSet.item, null, 2
    ###
    @item.reload () =>
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

    #@_ec2.call "DescribeTags", { "Filter.1.Name": "resource-id", "Filter.1.Value.1": @item.get "_id" }, outcome.e(callback).s (result) ->
    #  tags = module.exports.transformTags result
    #  callback null, tags

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