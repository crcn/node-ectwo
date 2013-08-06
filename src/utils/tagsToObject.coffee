
###
###

module.exports = (tags) ->
  obj = {}
  for tag in tags
    obj[tag.key] = tag.value

  return obj