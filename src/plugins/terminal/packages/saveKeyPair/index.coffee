fs = require "fs"
outcome = require "outcome"
mkdirp  = require "mkdirp"
path    = require "path"

exports.require = ["ectwo"]
exports.load = (ectwo) ->
  ectwo.fastener.options().keyPair.save = 
    type: "keyPair"
    call: (keyPath, next) ->

      if arguments.length is 1
        next = keyPath
        keyPath = "~/keys/#{@get('region')}/#{@get('name')}.pem"


      onSave = () =>  
        next null, @
        console.log("save keypair to %s", keyPath)

      keyPath = keyPath.replace("~", process.env.HOME)

      try
        mkdirp.sync path.dirname keyPath
      catch e
        console.log e.stack


      fs.writeFile keyPath, @get("material"), outcome.e(next).s onSave
