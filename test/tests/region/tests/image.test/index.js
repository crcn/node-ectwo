var async = require("async");
exports.require = ["region", "instance.test"];
exports.load = function(region, instance, loader, next) {
  describe("image", function() {


    var imageId, target;

    before(function() {
      imageId = loader.params("imageId");
    })

    after(function() {
      next(null, {
        target: target
      });
    });

    it("can be created from instance", function(done) {
      region.instances.findOne({ imageId: imageId }, done.s(function(instance) {
        instance.createImage({ name: "test" }, done.s(function(image) {
          expect(target = image).not.to.be(undefined);
          done();
        }));
      }));
    });

    it("can find an image", function(done) {
      region.images.findAll(done.s(function(images) {
        expect(images.length).not.to.be(0);
        done();
      }));
    });

    /*
    it("can fetch spot pricing", function() {
      region.images.findAll(done.s(function(images) {
        async.forEach(images, function(image, next) {
          image.getOneSpotPricing({ type: "t1.micro" }, outcome.e(next).s(function(pricing) {
            expect(pricing).not.to.be(undefined);
            next();
          }));
        }, done);
      }));
    });*/

  });
}