gumbo     = require "gumbo"
BaseModel = require "../../base/model"

###
###

module.exports = class extends BaseModel
  
  ###
  ###

  _destroy: (callback) ->
    callback new Error "Cannot remove pricing"