var async = require("async");
exports.require = ["region", "image.test"];
exports.load = function(region, instance, loader, next) {
  describe("instance tags", function() {

    var tags = { key: "test", value: "hello-" + Date.now() };


    after(function() {
      next(null, {
        tags: tags
      })
    });

    it("can be created", function(done) {
      instance.target.tags.create(tags, done.s(function() {
        instance.target.tags.findOne(tags, done.s(function(tag) {
          expect(tag).not.to.be(undefined);
          done();
        }));
      }));
    });

    it("can be used as a filter", function(done) {
      region.images.findOne({ tags: tags }, done.s(function(inst) {
        expect(inst).to.be(instance.target);
        done();
      }));
    });

    //sanity
    it("can be used as a filter without a result", function(done) {
      region.images.findOne({ tags: { key: "test", value: "wrong-value" } }, done.s(function(instance) {
        expect(instance).to.be(undefined);
        done();
      }));
    });
  });
}