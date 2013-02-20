// Generated by CoffeeScript 1.4.0
(function() {
  var BaseModel, async, gumbo, outcome, toarray,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  gumbo = require("gumbo");

  BaseModel = require("../base/model");

  outcome = require("outcome");

  async = require("async");

  toarray = require("toarray");

  module.exports = (function(_super) {

    __extends(_Class, _super);

    function _Class() {
      return _Class.__super__.constructor.apply(this, arguments);
    }

    /*
    */


    _Class.prototype.registerImage = function(options, callback) {
      var deviceName,
        _this = this;
      if (arguments.length === 1) {
        callback = options;
        options = {};
      }
      deviceName = "/dev/sda1";
      return this._ec2.call("RegisterImage", {
        "RootDeviceName": deviceName,
        "BlockDeviceMapping.1.DeviceName": deviceName,
        "BlockDeviceMapping.1.Ebs.SnapshotId": this.get("_id"),
        "Name": this.get("image.name") || String(Date.now())
      }, outcome.e(callback).s(function(result) {
        return _this.region.images.syncAndFindOne({
          _id: result.imageId
        }, callback);
      }));
    };

    /*
       Migrates the snapshot to another region - this is a mush
    */


    _Class.prototype.migrate = function(regions, callback) {
      var _this = this;
      return async.forEach(toarray(regions), (function(region, next) {
        return region.snapshots.copy({
          _id: _this.get("_id"),
          region: _this.get("region"),
          description: _this.get("description")
        }, next);
      }), callback);
    };

    /*
    */


    _Class.prototype._destroy = function(callback) {
      var _this = this;
      return this._ec2.call("DeleteSnapshot", {
        "SnapshotId.1": this.get("_id")
      }, outcome.e(callback).s(function() {
        return callback();
      }));
    };

    return _Class;

  })(BaseModel);

}).call(this);