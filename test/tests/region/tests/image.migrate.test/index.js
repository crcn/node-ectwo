exports.require = ["region", "image.test"];
exports.load = function(region, image, loader, next) {
  describe("image migration", function() {

    var img, tregion;

    before(function() {
      img = image.target;
    });

    after(function() {
      next(null, {
        region: tregion
      });
    });

    it("can migrate an image to another", function(done) {
      region.all.regions.findOne({ name: { $ne: region.get("name") }}, done.s(function(region) {
        expect(tregion = region).not.to.be(undefined);
        img.migrate(region, done.s(function(migrators) {
          migrators[0].on("completed", function() {
            console.log("DONE");
            done();
          })
        }));
      }));
    });
  });
}