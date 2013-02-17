var plugin = require("plugin"),
fs = require("fs"),
toarray = require("toarray"),
sift = require("sift");

exports.require = [];
exports.plugin = function(loader) {
  loader.params("regionsToTest").forEach(function(regionName) {
    describe("Region " + regionName, function() {



      var files = fs.readdirSync(__dirname + "/tests");

      var tester = sift({ $or: cleanupTests(loader.params("tests") || [".*"])}),
      toTest = files.filter(function(name) {
        return name != ".DS_Store" && tester.test(name);
      });

      for(var i = 0; i < toTest.length; i++) {
        var pg = toTest[i];
        if(~pg.indexOf("cleanup")) {
          var pluginParts = pg.split(".");
          pluginParts.shift();
          var newPlugin = pluginParts.join(".");

          if(newPlugin.length && !~toTest.indexOf(newPlugin) && !files.indexOf(newPlugin)) {
            toTest.push(newPlugin);
          }
        }
      }

      toTest = toTest.sort(function(a, b) {
        var ac = ~a.indexOf("cleanup"),
        bc = ~b.indexOf("cleanup");

        if((ac && bc) || (!ac && !bc)) {
          return a.length > b.length ? -1 : 1;
        } else {
          return ac ? 1 : -1;
        }
      });


      plugin().
      params({
        regionName: regionName,
        imageId: "ami-3d4ff254"
      }).
      require(__dirname + "/../../helpers").
      paths(__dirname + "/tests").
      require(toTest).
      load(); 
    });
  });
}


function cleanupTests(tests) {
  return toarray(tests).
  map(function(test) {
    if(typeof test == "string") {
      return new RegExp("^" + test + "$");
    }
    return test;
  })
}