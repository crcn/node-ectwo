var async = require("async");
exports.require = ["region", "instance.test", "instance.tags.test"];
exports.load = function(region, instance, tags, loader, next) {
  describe("instance tags", function() {

    after(function() {
      next();
    });

    it("can be removed", function(done) {
      instance.target.tags.remove(tags.tags, done.s(function() {
        instance.target.tags.findOne(tags.tags, done.s(function(tag) {
          expect(tag).to.be(undefined);
          done();
        }));
      }));
    });
  });
}