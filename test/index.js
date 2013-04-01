var plugin = require("plugin");

global.expect = require("expect.js");
global.outcome = require("outcome");
global.outcome.logAllErrors(true);


//monkeypatch "it" so it includes outcome.js
var oldIt = it;
it = function(message, callback) {
  if(callback.length == 0) return oldIt.call(this, message, callback);
  oldIt.call(this, message, function(done) {
    try {
      callback(outcome.e(function(e) {
        console.error(e.stack);
        done(e);
      }).s(function(r) {
        done(null, r);
      }));
    } catch(e) {
      console.error(e.stack);
      done(e)
    }
  });
} 

plugin().
params({
  regionsToTest: ["us-east-1"], //["us-east-1", "us-west-1", "us-west-2"]
  // tests: ["instance.test", "instance.cleanup"]
  // tests: [".*"]
  // tests: ["instance.tags.*", "image.tags.*", "instance.cleanup", "image.cleanup"]
  // tests: ["securityGroup.*"]
  tests: ["image.migrate.*", "instance.cleanup", "image.cleanup"]
}).
require(__dirname + "/helpers").
require(__dirname + "/tests").
load();