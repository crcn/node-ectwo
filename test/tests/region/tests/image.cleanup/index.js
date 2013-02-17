var async = require("async");
exports.require = ["region", "image.test"];
exports.load = function(region, image, loader, next) {
  describe("image", function() {

    after(function() {
      next();
    })


    it("can destroy all AMI's", function(done) {
      region.images.findAll(done.s(function(images) {
        async.forEach(images, function(image, next) {
          image.destroy(next);
        }, done);
      }));
    });

    it("can reload images", function(done) {
      region.images.load(done);
    });

    it("doesn't have anymore images", function(done) {
      region.images.findAll(done.s(function(images) {
        expect(images.length).to.be(0);
        done();
      }));
    });
  });
}