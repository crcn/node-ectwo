var sift = require("sift");
exports.require = ["image.test"];
exports.load = function(image, loader, next) {
  describe("image instance", function() {

    var img, inst;


    before(function() {
      img = image.target;
    });

    after(function() {
      next();
    })

    it("can be created", function(done) {
      img.createInstance(done.s(function(instance) {
        inst = instance;
        done();
      }));
    });

    it("has a vanilla flavored tag", function() {
      expect(sift({ key: "flavor", value: "vanilla"}, img.get("tags")).length).to.be(1);
    });
  });
}