var async = require("async");
exports.require = ["region", "address.test"];
exports.load = function(region, address, loader, next) {
  describe("address", function() {

    var target;

    after(function() {
      next(null, {
        target: target
      });
    });

    it("can release all addresses", function(done) {
      region.addresses.findAll(done.s(function(results) {
        async.forEach(results, function(address, next) {
          address.destroy(next);
        }, done);
      }));
    });
  });
}