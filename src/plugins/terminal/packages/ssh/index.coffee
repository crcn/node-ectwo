childProcess = require("child_process")
spawn        = childProcess.spawn

exports.require = ["ectwo"]
exports.load = (ectwo) ->
  ectwo.fastener.options().instance.ssh = 
    type: "ssh"
    onCall: () ->
      @root().emit "stopReadLine"

    call: (options, next) ->

      if arguments.length is 1
        next    = options
        options = {}

      unless options.user
        options.user = "root"

      next()

      console.log "ssh -t -t -i %s %s@%s", options.key, options.user, @get("dnsName")
      proc = spawn("ssh", ["-t","-t", "-i", options.key.replace("~", process.env.HOME), options.user + "@" + @get("dnsName")])
      proc.stdout.pipe(process.stdout)
      proc.stderr.pipe(process.stderr)
      process.stdin.pipe(proc.stdin)


