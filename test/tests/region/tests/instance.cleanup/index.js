var async = require("async");
exports.require = ["region", "instance.test"];
exports.load = function(region, instance, loader, next) {
  describe("instance cleanup", function() {

    var inst, imageId;

    before(function() {
      inst = instance.target;
      imageId = loader.params("imageId");
    });

    after(function() {
      next();
    });

    it("can be destroyed", function(done) {
      region.instances.findAll(done.s(function(instances) {
        expect(instances.length).not.to.equal(0);
        async.forEach(instances, function(instance, next) {
          instance.destroy(next);
        }, done);
      }));
    });

    it("has no immediate instances", function(done) {
      region.instances.findAll( done.s(function(instances) {
        expect(instances.length).to.equal(0);
        done();
      }));
    });

    it("has no reloaded instances", function(done) {
      region.instances.load(done.s(function() {
        region.instances.findAll(done.s(function(instances) {
          expect(instances.length).to.equal(0);
          done();
        }));
      }));
    });
  });
}