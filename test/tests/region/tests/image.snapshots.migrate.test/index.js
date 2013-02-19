var async = require("async"),
sift = require("sift");

exports.require = ["region", "image.snapshots.test"];
exports.load = function(region, image, loader, next) {
  describe("image snapshot", function() {

    after(function() {
      next();
    });
    

    var tsnap, tregion;

    it("can fetch the image snapshot", function(done) {
      region.images.findAll(done.s(function(images) {
        var image = image[0];
        assert(image).not.to.be(undefined);
        image.getSnapshot(done.s(function(snapshot) {
          assert(tsnap = snapshot).not.to.be(undefined);
          done();
        }));
      }));
    });

    it("can migrate a snapshot to another", function(done) {
      region.all.regions.findOne({ name: { $ne: region.get("name") }}, done.s(function(region) {
        console.log(region.name)
        expect(tregion = region).not.to.be(undefined);
        tsnap.migrate(region, done);
      }));
    });


    it("migrated snapshot actually exists", function(done) {
      tregion.snapshots.findAll(done.s(function(snapshots) {
        expect(snapshots.length).not.to.be(undefined);
      }));
    });
  });
}