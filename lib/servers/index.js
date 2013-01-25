var gumbo = require("gumbo"),
structr = require("structr"),
Sync = require("./sync");

module.exports = structr({


	/**
	 */

	"__construct": function(ec2) {
		this._ec2 = ec2;

		//the collection of servers 
		this.collection = gumbo.collection([]);

		//need to attach EC2 to the collection so each model item can access it for re-synchronizing
		//server info
		this.collection.ec2 = ec2;

		//sync the servers from ec2
		this._sync = new Sync(this.collection);
	},

	/**
	 * loads the instances
	 */

	"load": function(cb) {
 		this._sync.start(cb);
	},

	/**
	 * finds an instance using a mongodb query
	 */

	"find": function(query, cb) {
		return this.collection.find(query, cb);
	}
});