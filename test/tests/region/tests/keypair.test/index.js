exports.require = ["region"];
exports.load = function(region, loader, next) {
  describe("keypairs", function() {

    var keyName = "test-key",
    keypair;

    after(function() {
      next(null, {
        name: keyName,
        target: keypair
      });
    });

    it("can be created", function(done) {
      region.keyPairs.create(keyName, done.s(function(result) {
        keypair = result;
        expect(result).not.to.be(null);
        done();
      }));
    });
  });
}