var async = require("async");
exports.require = ["region", "instance.test","address.test"];
exports.load = function(region, instance, address, loader, next) {
  describe("instance address", function() {


    var target, inst, addr;

    before(function() {
      inst = instance.target;
    })

    after(function() {
      next();
    });


    it("can associate an address", function(done) {
      region.addresses.findOne({ instanceId: undefined }, done.s(function(address) {
        addr = address;
        address.associate(inst, function() {
          done();
        });
      }));
    });

    it("can find address from instance", function(done) {
      inst.getAddress(done.s(function(address) {
        expect(address).not.to.be(undefined);
        done();
      }));
    });

    it("can find instance from address", function(done) {
      addr.getInstance(done.s(function(instance) {
        expect(instance).not.to.be(undefined);
        done();
      }));
    });
  });
}