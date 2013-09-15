packages = require "packages"

module.exports = (ectwo) ->
  packages().
  require({ ectwo: ectwo }).
  require(__dirname + "/packages").
  load()
