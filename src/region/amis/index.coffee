gumbo = require "gumbo"
_ = require "underscore"
ImageModel = require "./ami"


###
 A collection of ALL Amazon Machine Images
###

module.exports = class extends gumbo.Collection

	###
	###
	
	constructor: (@region) ->
		@ec2 = region.ec2
		super [], _.bind(this._createModel, this)

		# synchronizer makes sure the data in gumbo.collection is the same as what's on the remote
		# host
		@_sync = @synchronizer { uniqueKey: "imageId", load: _.bind(@._load, @) }

	###
	###

	createAMI

	###
	 Starts the synchronization process
	###

	load: (callback) ->
		@_sync.start callback

	###
	###

	_createModel: (collection, item) ->
		item.region = @region.get "name"
		return new ImageModel collection, @region, item

	###
	 Loads the remote collection
	###

	_load: (onLoad) ->


    @ec2.call "DescribeImages", { "Owner.1": "self" }, (err, result) =>
      return onLoad(null, []) if not result.imagesSet.item
      images = if result.imagesSet.item not instanceof Array then [result.imagesSet.item] else result.imagesSet.item
      onLoad null, images


		