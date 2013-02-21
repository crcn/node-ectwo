fs   = require "fs"
path = require "path"

fs.readdirSync(__dirname).forEach((file) ->

  basename = path.basename(file)

  return if basename is "index" or not /(js|coffee)$/.test file

  exports[basename] = require "#{__dirname}/#{basename}"
)