var ectwo = require("ectwo")();


ectwo.servers.find({ tags: { type: "production", group: "redis" } }, function(err, servers) {
	// server.tags.fsdfsdfs;

});


ectwo.amis.findOne({ group: "redis" }).launchSpot({ count: 4, persistent: false, flavor: "c1.medium" }, function(err, servers) {
	servers.forEach(function(server) {
		server.terminate();
	});
	
});


process.fork(function() {

});