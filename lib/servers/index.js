var gumbo = require("gumbo"),
structr = require("structr");

module.exports = structr({


	/**
	 */

	"__construct": function(ec2) {
		this._ec2 = ec2;
		this._col = gumbo.collection();
	},

	/**
	 */

	"load": function() {

	}
});