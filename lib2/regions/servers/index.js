// Generated by CoffeeScript 1.4.0
(function() {
  var ServerModel, Sync, comerr, gumbo, _;

  gumbo = require("gumbo");

  ServerModel = require("./server");

  Sync = require("./sync");

  comerr = require("comerr");

  _ = require("underscore");

  module.exports = (function() {
    /*
    */

    function _Class(region) {
      this.region = region;
      this.collection = gumbo.collection([], _.bind(this._createModel, this));
      this.sync = new Sync(this);
    }

    /*
    	 Function: load
    */


    _Class.prototype.load = function(callback) {
      return this.sync.start(callback);
    };

    /*
    */


    _Class.prototype._createModel = function(collection, item) {
      return new ServerModel(collection, ec2, item);
    };

    return _Class;

  })();

}).call(this);
