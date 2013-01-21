var structr = require("structr"),
aws = require("aws-lib"),
Servers = require("./servers"),
async = require("async"),
gumbo = require("gumbo"),
syncAMIs = require("./sync/amis"),
syncServers = requrie("./sync/servers");

structr.mixin(require("structr-step"));

var ECTwo = structr({

	/**
	 */

	"__construct": function(config) {
		this._ec2 = aws.createEC2Client(config.key, config.secrey);
		this._servers = 

		this.load();
	},

	/**
	 * loads EC2 servers, amis, etc.
	 */

	"load": function(next) {
		var self = this;
		async([this._servers], function(loadable, next) {
			loadable.load(function() {
				self[loadable.type] = loadable.collection;
			});
		}, next);
	}
});


module.exports = function(config) {
	return new ECTwo(config);
}