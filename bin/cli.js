var fasten = require("fasten"),
ectwo      = require(".."),
toarray    = require("toarray"),
readline = require("readline"),
compileCommand = require("./compileCommand"),
dref = require("dref");


require("colors");


fastener = fasten();
var history = []

function logResult(result) {
  toarray(result).forEach(function(res) {
    console.log(String(res));
  })
}

function readCommand(callback) {
  if(!callback) callback = function(){};
  var rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  rl.history = history;
  process.stdout.write("> ");

  rl.on("line", function(cmd) {
    history.push(cmd);
    rl.close();
    try {
      var fn = compileCommand(cmd);
      callback(fn);
    } catch(e) {
      console.error("Unable to interpret command: %s", cmd);
      console.error(e.stack);
      readCommand(callback);
    }
  });
}


function runLoader() {
  var numDots = 0;
  var interval = setInterval(function() {
    process.stdout.write(".");
    numDots++;
  }, 1000);
  
  return function() {
    clearInterval(interval);
    if(numDots) console.log("");
  }
}

function collection(itemType) {
  return {
    find: {
      type: itemType,
      params: ["query"],
      onResult: logResult
    },
    findOne: {
      type: itemType,
      params: ["query"],
      onResult :logResult
    },
    findAll: {
      type: itemType,
      onResult: logResult
    }
  }
}

fastener.add("regions", collection("region")).add("region", {
  "instances": {
    type: "instances",
    call: function(next) {
      next(null, this.instances);
    }
  }
}).add("instances", collection("instance")).add("instance", {
  info: {
    type: "instance",
    call: function() {
      var args = Array.prototype.slice.call(arguments, 0),
      next = args.pop(),
      inf = {}

      if(args.length) {
        for(var i = args.length; i--;) {
          inf[args[i]] = this._data[args[i]];
        }
      } else {
        inf = this._data;
      }

      next(null, inf);
    },
    map: function() {
      return this;
    },
    onResult: function(result) {
      console.log(result);
    }
  },
  start: {
    type: "instance",
    map: function() { return this; }
  },
  stop: {
    type: "instance",
    map: function() { return this; }
  },
  reboot: {
    type: "instance",
    map: function() { return this; }
  },
  createImage: {
    type: "image"
  },
  getImage: {
    type: "image"
  },
  getAddress: {
    type: "address"
  },
  setAddress: {
    type: "address"
  }
}).
add("images", collection("image")).add("image", {
  createInstance: {
    type: "instance"
  },
  getSnapshot: {
    type: "snapshot"
  },
  getOneSpotPricing: {
    type: "spotPricing",
    params: ["options"]
  },
  createSpotRequest: {
    type: "spotRequest",
    params: ["options"]
  },
  migrate: {
    type: "image",
    params: ["options"]
  }
})

var ops = fastener._callChainOptions,
help = [];

for(var type in ops) {
  var methods = ops[type];
  for(var method in methods) {
    var methodOps = methods[method],
    params = methodOps.params || [];

    help.push({ name: [type, ".", method, "("+params.join(",")+")"].join("") })
  }
}



module.exports = function(options) {

  var commands = options.commands,
  config       = options.config,
  interactive  = !!options.interactive,
  regions      = options.regions || ectwo.regions;


  var ec2 = ectwo({
    key: config.key,
    secret: config.secret
  }, regions);


  var cli = {
    help: function() {

      for(var i = help.length; i--;) {
        console.log("  %s", help[i].name);
      }

      console.log("");

    },
    regions: fastener.wrap("regions", ec2.regions),
    instances: fastener.wrap("instances", ec2.instances),
    images: fastener.wrap("images", ec2.images)
  }


  var hasError = false;

  fastener.on("call", function(result) {

    var name = String(result.target);
    if(name == "[object Object]") {
      name = result.type;
    }

    console.log("%s.%s()".cyan, name, result.method);
    var killLoader = runLoader();

    result.chain.once("result", function() {
      killLoader();
    }).
    once("error", function(err) {
      killLoader();
      hasError = true;
      console.error("Error: %s", err.message);
    })
  });


  for(var i = 0, n = commands.length; i < n; i++) {
    runCommand(commands[i]);
  }

  fastener.then(runInput);

  function runCommand(command) {
    command(cli);    
  }

  function runInput() {
    if(!interactive) {
      process.exit(Number(hasError));
      return;
    }
    readCommand(function(command) {
      runCommand(command);
      fastener.then(runInput);
    }); 
  }


}