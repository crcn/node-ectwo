exports.require = ["region", "image.test"];
exports.load = function(region, image, loader, next) {
  describe("image snapshot", function() {

    var img;

    before(function() {
      img = image.target;
    });

    after(function() {
      next();
    });

    it("has a snapshot", function(done) {
      region.snapshots.findAll(done.s(function(snapshots) {
        expect(snapshots.length).not.to.be(0);
        done();
      }));
    });

    it("can fetch image snapshot", function(done) {
      img.getSnapshot(done.s(function(snapshot) {
        expect(snapshot).not.to.be(undefined);
        done();
      }));
    });
  });
}