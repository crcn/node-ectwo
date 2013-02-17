var async = require("async");

exports.require = ["region"];
exports.load = function(region, loader, next) {
  describe("spot requests", function() {

    var pricing, imageId = loader.params("imageId");

    after(function() {
      next(null, {
        pricing: pricing
      });
    });

    it("can fetch spot pricing", function(done) {
      region.spotRequests.pricing.findAll(done.s(function(pricing) {
        expect(pricing.length).not.to.be(0)
        done();
      }));
    });

    it("can fetch linux pricing", function(done) {
      region.spotRequests.pricing.findOne({ platform: "linux", type: "t1.micro" }, done.s(function(pr) {
        pricing = pr;
        expect(pr).not.to.be(undefined);
        done();
      }));
    });

    it("can create a spot request", function(done) {
      region.spotRequests.create({ price: pricing.get("price"), imageId: imageId, type: pricing.get("type") }, done.s(function(sr) {
        expect(sr).not.to.be(undefined);
        done();
      }));
    });

    it("can reload spot requests", function(done) {
      region.spotRequests.load(done);
    });
  });
}