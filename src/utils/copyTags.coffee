_            = require "underscore"
objectToTags = require "./objectToTags"
tagsToObject = require "./tagsToObject"

###
###

module.exports = (from, to, additionalTags, next) ->

  if arguments.length is 3
    next = additionalTags
    additionalTags = {}

  tags = tagsToObject (from.get("tags") or [])
  _.extend tags, additionalTags

  to.tags.create objectToTags(tags), next