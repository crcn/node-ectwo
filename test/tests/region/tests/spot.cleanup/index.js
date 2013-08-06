var async = require("async");

exports.require = ["region", "spot.test"];
exports.load = function(region, spot, loader, next) {
  describe("spot cleanup", function() {

    after(function() {
      next();
    });

    it("can destroy all spot instance requests", function(done) {
      region.spotRequests.findAll(done.s(function(requests) {
        async.forEach(requests, function(request, next) {
          request.destroy(next);
        }, done);
      }));
    });

    it("can reload spot requests", function(done) {
      region.spotRequests.load(done);
    });

    it("doesn't have any spot requests", function(done) {
      region.spotRequests.findAll(done.s(function(requests) {
        expect(requests.length).to.be(0);
        done();
      }));
    });
  });
}