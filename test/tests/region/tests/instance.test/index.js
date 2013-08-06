var async = require("async"),
sift = require("sift");

exports.require = ["region"];
exports.load = function(region, loader, next) {
  describe("instance", function() {

    var inst;

    after(function() {
      next(null, {
        target: inst
      })
    });

    it("can be created", function(done) {
      region.images.createInstance({
        imageId: loader.params("imageId"),
        flavor: "t1.micro", 
        tags: {
          flavor: "vanilla"
        }
      }, done.s(function(instance) {
        expect(inst = instance).not.to.be(undefined);
        done();
      }));
    });

    it("has a vanilla flavored tag", function() {
      expect(sift({ key: "flavor", value: "vanilla"}, inst.get("tags")).length).to.be(1);
    });

    it("can still be found", function(done) {
      region.instances.findOne({ _id: inst.get("_id") }, done.s(function(instance) {
        expect(instance).not.to.be(undefined);
        done();
      }));
    });

    it("can reload an instance", function(done) {
      inst.reload(done);
    });
  });
}