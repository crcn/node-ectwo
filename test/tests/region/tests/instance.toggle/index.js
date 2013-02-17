var async = require("async");
exports.require = ["region", "instance.test"];
exports.load = function(region, instance, loader, next) {
  describe("instance", function() {

    var inst;

    before(function() {
      inst = instance.target;
    });

    after(function() {
      next();
    });


    it("can be stopped", function(done) {
      inst.stop(done.s(function() {
        expect(inst.get("state")).to.equal("stopped");
        done();
      }));
    });

    it("can be started", function(done) {
      inst.start(done.s(function() {
        expect(inst.get("state")).to.equal("running");
        done();
      }));
    });

    it("skips start if already started", function(done) {
      inst.start(done.s(function() {
        expect(inst.get("state")).to.equal("running");
        done();
      }));
    })
    
    it("can be stopped again", function(done) {
      inst.stop(done.s(function() {
        expect(inst.get("state")).to.equal("stopped");
        done();
      }));
    });
  });
}