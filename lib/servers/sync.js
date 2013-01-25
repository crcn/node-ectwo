var structr = require("structr"),
EventEmitter = require("events").EventEmitter,
_ = require("underscore"),
comerr = require("comerr"),
step = require("step");

/**
 * synchronizes the server states form EC2 with the servers stored in mem
 */


module.exports = structr(EventEmitter, {


	/**
	 */

	"__construct": function(collection) {
		this._ec2 = collection.ec2;
		this._collection = collection;
	},

	/**
	 * starts 
	 */

	"start": function(cb) {

		if(!cb) cb = function(){};
		if(this._stated) return cb(new comerr.AlreadyCalled("Cannot recall start"));

		//listen for the first time "update" is emitted
		this.once("updated", cb);


		//start the timer for updating all the servers from EC2
		setInterval(_.bind(this.update, this), 1000 * 10);
		this.update();
	},

	/**
	 */

	"update": function() {
		console.log("updating servers");
		this._ec2.call("DescribeInstances", {}, function(err, result) {
			console.log("OK")
		});

		
	}

});


