childProcess = require("child_process")
exec         = childProcess.exec
sprintf      = require("sprintf").sprintf
type         = require "type-component"
fs           = require "fs"

exports.require = ["ectwo", "utils"]
exports.load = (ectwo, utils) ->
  ectwo.fastener.options().instance.exec = 
    type: "ssh"
    onCall: () ->
      #@root().emit "interceptReadline", ()

    call: (options, next) ->

      if arguments.length is 1
        next    = options
        options = {}

      if type(options) is "string"
        options = { cmd: options }

      unless options.user
        options.user = "ubuntu"

      unless options.key
        options.key = utils.defaultKeyPath(@get("region"), @get("keyName"))


      options.cmd = options.cmd.replace("~", process.env.HOME).replace(/^\./, process.cwd())

      tmpFile = "/tmp/ectwo-script.sh"

      if fs.existsSync(options.cmd)
        orgFile = options.cmd
      else
        orgFile = "/tmp/ectwo-script.sh"
        fs.writeFileSync tmpFile, options.cmd, { mode: 755 }

      cmd = sprintf("ssh -t -t -i %s %s@%s 'sh /tmp/ectwo-script.sh'", options.key, options.user, @get("dnsName"))

      cmd = sprintf("scp -i %s %s %s@%s:%s; %s", options.key, orgFile, options.user, @get("dnsName"), tmpFile, cmd)

      console.log cmd
      proc = exec cmd, () -> next()
      delete proc.stdout._events.data
      delete proc.stderr._events.data
      proc.stdout.pipe(process.stdout)
      proc.stderr.pipe(process.stderr)


