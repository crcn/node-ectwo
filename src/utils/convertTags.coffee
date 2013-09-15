toarray = require "toarray"
type    = require "type-component"

module.exports = (data) ->
  tagsAr = toarray(data.tagSet?.item)
  tags = {}
  for tag in tagsAr
    continue if type(tag.value) is "object"
    tags[tag.key] = tag.value
  tags
