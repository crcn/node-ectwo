var async = require("async");
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
        flavor: "t1.micro"
      }, done.s(function(instance) {
        expect(inst = instance).not.to.be(undefined);
        done();
      }));
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