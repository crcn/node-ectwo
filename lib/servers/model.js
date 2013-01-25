var structr = require("structr"),
gumb = require("gumbo"),
step = require("step");

module.exports = structr(gumbo.BaseModel, {

	/**
	 */

	"override __construct": function(collection, target) {
		this._super(collection, target);

		this._ec2 = collection.ec2;
	},

	/**
	 * refreshes the server from EC2
	 */

	"refresh": function() {

	},

	/**
	 * starts the server if it's in the OFF stated
	 */

	"start": function(cb) {

	},

	/**
	 * stops the server
	 */

	"stop": function(cb) {

	},

	/**
	 * restarts the server
	 */

	"restart": function(cb) {

	},

	/**
	 * destroys the server
	 */

	"terminate": function(cb) {

	},

	/** 
	 * creates an Amazon Machine Image from this server. Note - if the server is running, then
	 * it'll be stopped.
	 * @return the new AMI created
	 */

	"createAMI": function(cb) {

	},

	/**
	 * clones this server with the given AMI, and flavor (micro, m1.small, m1.medium, c1.medium)
	 */

	"clone": function(cb) {

	}

});