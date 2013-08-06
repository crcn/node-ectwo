var fasten = require("fasten"),
ectwo      = require(".."),
celeri     = require("celeri"),
toarray    = require("toarray");

require("colors");


fastener = fasten()

function logResult(result) {
  toarray(result).forEach(function(res) {
    console.log(String(res));
  })
}

function logCommand(type, result) {
}


fastener.add("regions", {
  find: {
    type: "region",
    onResult: logResult
  },
  findOne: {
    type: "region",
    onResult :logResult
  },
  findAll: {
    type: "region",
    onResult: logResult
  }
}).add("region", {
  "instances": {
    type: "instances",
    call: function(next) {
      next(null, this.instances);
    }
  }
}).add("instances", {
  find: {
    type: "instance",
    onResult: logResult
  },
  findOne: {
    type: "instance",
    onResult: logResult
  },
  findAll: {
    type: "instance",
    onResult: logResult
  }
}).add("instance", {
  info: {
    type: "instance",
    call: function(next) {
      next(null, this._data);
    },
    map: function() {
      return this;
    },
    onResult: function(result) {
      console.log(result);
    }
  },
  start: {
    type: "instance"
  },
  stop: {
    type: "instance"
  },
  reboot: {
    type: "instance"
  },
  createImage: {
    type: "image"
  }
})



module.exports = function(options) {
  var commands = options.commands,
  config       = options.config;

  var ec2 = ectwo({
    key: config.key,
    secret: config.secret
  }, config.regions);


  var cli = {
    help: function() {

      var ops = [
        { command: "help()"                           , desc: "show help menu"    },
        { command: "regions.find(query)"              , desc: "list specific regions" },
        { command: "regions.findOne(query)"           , desc: "find one region"  },
        { command: "regions.findAll()"                , desc: "list all regions" },
        { command: "region.instances.find(query)"     , desc: "find one instance" },
        { command: "region.instances.findOne(query)"  , desc: "find all specific regions" },
        { command: "instances.find(query)"            , desc: "finds an instance" },
        { command: "instances.find(query)"            , desc: "finds an instance" }
      ].reverse()

      celeri.drawTable(ops, { 
        columns: {
          command: {
            width: 10
          },
          desc: {
            width: 20
          }
        },
        pad: {
          top: 1,
          left: 3,
          bottom: 1
        }
      });
    },
    regions: fastener.wrap("regions", ec2.regions),
    instances: fastener.wrap("instances", ec2.instances)
  }



  for(var i = 0, n = commands.length; i < n; i++) {
    var call = commands[i](cli);

    if(!call || !call.on) continue;

    call.root().on("call", function(result) {

      var name = String(result.target);
      if(name == "[object Object]") {
        name = result.type;
      }


      var loader = celeri.loading(name + "." + result.method + "() ");

      result.chain.once("result", function() {
        loader.done();
      }).
      once("error", function(err) {
        loader.done(err);
        console.error("Error: %s", err.message);
      })
    })
  }
}