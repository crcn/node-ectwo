async   = require "async"
cstep   = require "cstep"
outcome = require "outcome"
flatten = require "flatten"

module.exports = class
    
  ###
    Function: 

    Parameters:
  ###

  constructor: (@ectwo, @collectionType) ->

  ###
    Function: 

    Parameters:
  ###

  load: () ->
    cstep(@).add @ectwo

  ###
    Function: 

    searches through ALL the data centers for servers with the given query

    Parameters:
  ###

  find: cstep (query, callback) ->
    async.map @_regions(), ((region, next) =>
      region[@collectionType].find(query).exec next
    ), outcome.e(callback).s (results) ->
      callback null, flatten results
      

  ###
    Function: 

    Parameters:
  ###

  findOne: cstep (query, callback) ->


  ###
    Function: 

    Parameters:
  ###

  _regions: () -> @ectwo.regions.findAll().sync()





