// Generated by CoffeeScript 1.4.0
(function() {
  var Sync;

  Sync = require("./sync");

  module.exports = (function() {

    function _Class(region) {
      this.region = region;
      this.sync = new Sync(this);
    }

    _Class.prototype.load = function(callback) {
      return this.sync.start(callback);
    };

    return _Class;

  })();

}).call(this);
