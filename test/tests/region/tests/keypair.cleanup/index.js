async = require("async");
exports.require = ["region", "keypair.test"];
exports.load = function(region, keypair, loader, next) {
  describe("keypair cleanup", function() {

    after(function() {
      next();
    });

    it("can be destroyed", function(done) {
      region.keyPairs.findOne({ name: keypair.name }, done.s(function(result) {
        expect(result).not.to.be(undefined);
        result.destroy(done);
      }));
    });

    it("doesn't exist anymore", function(done) {
      region.keyPairs.findOne({ name: keypair.name }, done.s(function(result) {
        expect(result).to.be(undefined);
        done();
      }));
    });

    it("can destroy all keypairs", function(done) {
      region.keyPairs.findAll(done.s(function(keyPairs) {
        async.forEach(keyPairs, function(keyPair, next) {
          keyPair.destroy(next);
        }, done);
      }))
    });

    it("can reload keypairs", function(done) {
      region.keyPairs.load(done);
    });

    it("doesn't have anymore keypairs", function(done) {
      region.keyPairs.findAll(done.s(function(keyPairs) {
        expect(keyPairs.length).to.equal(0);
        done();
      }))
    })
  });
}