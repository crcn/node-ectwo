// Generated by CoffeeScript 1.4.0
(function() {
  var outcome;

  outcome = require("outcome");

  module.exports = function(ec2, type, callback) {
    return ec2.call("DescribeTags", {
      "Filter.1.Name": "resource-type",
      "Filter.1.Value.1": type
    }, outcome.e(callback).s(function(result) {
      var tags;
      if (!result.tagSet.item) {
        return callback(null, []);
      }
      tags = result.tagSet.item instanceof Array ? result.tagSet.item : [result.tagSet.item];
      return callback(null, tags);
    }));
  };

}).call(this);