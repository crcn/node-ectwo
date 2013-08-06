var async = require("async");
exports.require = ["region", "securityGroup.test"];
exports.load = function(region, securityGroup, loader, next) {
  describe("security group cleanup", function() {
    var groupName = "test-group",
    target;

    after(function() {
      next();
    });


    it("can be destroyed", function(done) {
      region.securityGroups.findOne({ name: securityGroup.name }, done.s(function(group) {
        securityGroup.target.destroy(done);
      }));
    }); 

    it("can destroy all security groups", function(done) {
      //default is reserved
      region.securityGroups.find({ name: {$ne: "default"} }, done.s(function(securityGroups) {
        async.forEach(securityGroups, function(sg, next) {
          sg.destroy(next);
        }, done);
      }))
    });

    it("can reload security groups", function(done) {
      region.securityGroups.load(done);
    });

    it("doesn't have anymore security groups", function(done) {
      region.securityGroups.find({ name: {$ne: "default"} }, done.s(function(securityGroups) {
        expect(securityGroups.length).to.be(0);
        done();
      }));
    });
  });
}