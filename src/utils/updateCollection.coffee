
module.exports = (collection, items, idKey, callback) ->
	objectsById = {}

	objectIds = items.map (item) ->
		objectsById[item[idKey]] = item
		return item[idKey]

	search = { }
	search[idKey] = { $in: objectIds }


	# first try to update the items that already exist
	collection.find(search).sync().forEach (image) ->
		id = image.get idKey
		image.update objectsById[id]
		items.splice items.indexOf(objectsById[id]), 1


	# the insert the new items
	collection.insert(items, callback).exec(callback)


