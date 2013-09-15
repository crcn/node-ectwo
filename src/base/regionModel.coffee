type = require "type-component"
outcome = require "outcome"
hurryup = require "hurryup"

class BaseRegionModel extends require("./model")

  ###
  ###

  constructor: (data, collection) ->
    super data, collection

    @region = @collection.region
    @api    = @region?.api


  ###
  ###

  toString: () ->
    @get("_id")

  ###
    adds a tag
  ###

  tag: (nameOrTags, value, next) ->

    if arguments.length is 2
      next  = value
      value = undefined
      tags = nameOrTags
    else 
      tags = {}
      tags[nameOrTags] = value

    createTags = {}
    deleteTags = {}

    i = 1
    for name of tags
      tag = tags[name]

      if tag?
        createTags[name] = String(tag)
      
      deleteTags[name] = undefined


      # tagging doesn't always work with EC2 - depends on the state
      # of the instance / image
      tryTagging = (next) =>
        @_modifyTags "CreateTags", createTags, outcome.e(next).s () =>
          @reload () =>
            unless @synced({ tags: createTags })
              return next new Error "tag changes haven't been made"

            next null, @

      @_modifyTags "DeleteTags", deleteTags, () =>
        hurryup(tryTagging, { timeout: 1000 * 60 * 3, retry: true, retryTimeout: 1000 }).call @, next




  ###
  ###

  _modifyTags: (method, tags, next) ->

    query = {
      "ResourceId.1": @get("_id")
    }

    i = 0
    for name of tags
      query["Tag.#{++i}.Key"] = name
      if tags[name]?
        query["Tag.#{i}.Value"] = tags[name]

    return next() if i is 0

    @api.call method, query, next


module.exports = BaseRegionModel