_ = require "underscore"
EventEmitter = require("events").EventEmitter
outcome = require "outcome"

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

      if @_currentProgress isnt @snapshot.get "progress"
        @_currentProgress = @snapshot.get "progress"
        @emit "progress", @_currentProgress

      console.log @_currentProgress

      # snapshot done moving over?
      if @snapshot.get("progress") is 1
        @_registerImage()


  ###
  ###

  _registerImage: () ->
    @snapshot.registerImage {
      _id: @snapshot.get("_id"),
      name: @image.get("name")
    }, outcome.e(done).s (image) ->
      @emit "complete", image