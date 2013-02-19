var async = require("async");
exports.require = ["region", "image.cleanup"];
exports.load = function(region, image, loader, next) {

  // no cleanup for now - doesn't work unless the snapshot isn't associated 
  // with an image
  return next();
  
  describe("image snapshot clean", function() {


    after(function() {
      next();
    });


    it("can remove all snapshots", function(done) {
      region.snapshots.findAll(done.s(function(snapshots) {
        async.forEach(snapshots, function(snapshot, next) {
          snapshot.destroy(done);
        }, done);
      }));
    });

    it("can reload all snapshots", function(done) {
      region.snapshots.load(done);
    });

    it("doesn't have anymore snapshots", function(done) {
      region.snapshots.findAll(done.s(function(snapshots) {
        expect(snapshots.length).to.be(0);
        done();
      }));
    });
  });
}