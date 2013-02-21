_ = require "underscore"
EventEmitter = require("events").EventEmitter
outcome = require "outcome"
copyTags = require "../../../utils/copyTags"

###
 Keeps tabs on the current progress for migrating an image. 
###

module.exports = class extends EventEmitter
  
  ###
  ###

  constructor: (@image, @snapshot) -> 
    @_start()

  ###
  ###

  _start: () ->
    return if @_completed
    @_stop()

    @_timeout = setInterval _.bind(@_updateProgress, @), 1000 * 5

  ###
  ###

  _stop: () ->
    clearTimeout @_timeout


  ###
  ###

  _updateProgress: () ->

    @snapshot.reload () =>

      if (@_currentProgress is undefined) or (@_currentProgress isnt @snapshot.get("progress"))
        @_currentProgress = @snapshot.get("progress") or 0
        @emit "progress", @_currentProgress

      # snapshot done moving over?
      if @snapshot.get("progress") is 100
        @_registerImage()


  ###
  ###

  _registerImage: () ->
    @_stop()

    o = outcome.e(_.bind(@_error, @))

    @snapshot.registerImage {
      _id: @snapshot.get("_id"),
      name: @image.get("name")
    }, o.s (image) =>

      # finally, copy the tags over.
      copyTags @image, image, o.s () =>
        @emit "complete", image


  ###
  ###

  _error: (err) ->
    @emit "error", err