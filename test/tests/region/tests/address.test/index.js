var async = require("async");
exports.require = ["region"];
exports.load = function(region, loader, next) {
  describe("address", function() {

    var target;

    after(function() {
      next(null, {
        target: target
      });
    });

    it("can allocate a new address", function(done) {
      region.addresses.allocate(done.s(function(address) {
        expect(target = address).not.to.be(undefined);
        done();
      }));
    });
  });
}