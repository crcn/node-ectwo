var async = require("async");
exports.require = ["region", "image.migrate.test"];
exports.load = function(region, image, loader, next) {

  //
  return next();
  describe("image migration cleanup", function() {

    var tregion;

    before(function() {
      tregion = image.region;
    });

    after(function() {
      next();
    });

    it("can remove all images from migrated region", function(done) {
      tregion.images.findAll(done.s(function(images) {
        async.forEach(images, function(image, next) {
          image.destroy(next);
        }, done);
      }));
    });
  });
}