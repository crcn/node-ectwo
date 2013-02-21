EventEmitter = require("events").EventEmitter

module.exports = class extends EventEmitter

  ###
  ###

  constructor: (@migrators) ->

    @_images = []
    @_progresses = []

    for migrator,i in @migrators
      @_progresses.push 0
      @_watchMigrator migrator, i


  ###
  ###

  _watchMigrator: (migrator, i) ->

    migrator.on "progress", (progress) =>
      @_progresses[i] = progress

      sum = 0

      for p in @_progresses
        sum += p

      @_totalProgress = Math.round sum / @_progresses.length

      @emit "progress", @_totalProgress


    migrator.on "complete", (image) =>
      @_images.push(image)

      console.log @_images.length, @_progresses.length
      if @_images.length is @_progresses.length
        @emit "complete", @_images
