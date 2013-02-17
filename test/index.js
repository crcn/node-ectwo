var plugin = require("plugin");

global.expect = require("expect.js");
global.outcome = require("outcome");


//monkeypatch "it" so it includes outcome.js
var oldIt = it;
it = function(message, callback) {
  if(callback.length == 0) return oldIt.call(this, message, callback);
  oldIt.call(this, message, function(done) {
    callback(outcome.e(done).s(function(r) {
      done(null, r);
    }));
  });
}



plugin().
params({
  regionsToTest: ["us-east-1"], //["us-east-1", "us-west-1", "us-west-2"]
  tests: [".*"]
}).
require(__dirname + "/helpers").
require(__dirname + "/tests").
load();