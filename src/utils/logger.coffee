winston = require "winston"

###
###

exports.child = (message, parent) ->
  
  
  logger = {
    child: (message) => exports.child message, logger
    prefix: () ->
      (if parent then parent.prefix() + " " else "") + message
  }

  ["info", "warn", "error"].forEach (level) ->
    logger[level] = () ->
      arguments[0] = logger.prefix() + " " + arguments[0]
      winston[level].apply winston, arguments

  logger