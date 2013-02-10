gumbo = require "gumbo"
toarray = require "toarray"
Tag = require "./tag"
_ = require "underscore"
toarray = require "toarray"


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
    @_call @_prepareQuery(tags), "CreateTags", reload isnt false, callback


  ###
  ###

  remove: (tags, callback, reload) ->
    @_call @_prepareQuery(tags), "DeleteTags", reload isnt false, callback

  ###
  ###

  update: (tags, callback) ->
    @remove(tags, (() =>
      @create tags, callback
    ), false)


  ###
  ###

  _call: (data, command, reload, callback) ->
    self = this
    @_ec2.call command, data, (err, result) ->

      console.log result
    
      onReload = () =>  
        self._sync.load () =>
          callback.apply(this, arguments)

      return onReload if not reload 

      # test if tags are being synchronized properly
      #self._ec2.call "DescribeInstances", {"InstanceId.1": self.item.get "_id" }, (err, result) ->
        #console.log JSON.stringify result.reservationSet.item, null, 2
        
      self.item.reload onReload





  ###
  ###

  _prepareQuery: (tags) ->

    tags = toarray tags

    toUpdate = {
      "ResourceId.1": @item.get "_id"
    }

    for tag, i in tags
      toUpdate["Tag.#{i}.Key"]   = tag.key
      toUpdate["Tag.#{i}.Value"] = tag.value

    toUpdate

  ###
  ###

  _createTag: (collection, item) ->
    new Tag collection, item, @


  ###
  ###

  _loadTags: (options, onLoad)  ->
    tags = @item.get "tags"
    onLoad null, tags



###
###

module.exports.transformTags = (rawData) ->
  toarray(rawData.tagSet).
  map((tagSet) ->
    tag = tagSet.item
    {
      _id   : "#{tag.key}-#{tag.value}",
      key   : tag.key,
      value : tag.value
    }
  )
