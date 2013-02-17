var async = require("async");
exports.require = ["region", "instance.address.test"];
exports.load = function(region, address, loader, next) {
  describe("instance address", function() {

    var target;

    after(function() {
      next();
    });


    it("can disassociate an address", function(done) {
      region.addresses.find({ instanceId: {$ne: undefined } }, done.s(function(addresses) {
        async.forEach(addresses, function(address, next) {
          address.disassociate(next);
        }, done);
      }));
    });

    it("doesn't have anymore associated address", function(done) {
      region.addresses.find({ instanceId: {$ne: undefined } }, done.s(function(addresses) {
        expect(addresses.length).to.be(0);
        done();
      }));
    });
  });
}