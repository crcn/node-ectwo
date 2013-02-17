exports.require = ["region"];
exports.load = function(region, loader, next) {
  describe("security group", function() {
    var groupName = "test-group",
    target;

    after(function() {
      next(null, {
        name: groupName,
        target: target,
      });
    });

    it("can be created", function(done) {
      region.securityGroups.create(groupName, done.s(function(result) {
        expect(target = result).not.to.be(null);
        done()
      }));
    });

    it("can add ingress", function(done) {
      region.securityGroups.findOne({ name: groupName }, done.s(function(result) {
        result.authorizePorts(8080, done.s(function(result) {
          done();
        }));
      }));
    });
  });
}