
exports.require = ["ectwo"];

exports.load = function(ectwo, loader, next) {
  it("can be fetched", function(done) {

    ectwo.regions.findOne({ name: loader.params("regionName") }, done.s(function(region) {
      expect(region).not.to.be(undefined);
      next(null, region);
      done();
    }));
  }); 
}