
exports.require = ["ectwo"];
exports.plugin = function(ectwo) {

  describe("ECTwo region collection", function() {

    it("can add a NULL region controller", function() {
      ectwo.instances.controllerFactory.addControllerClass({ name: "ectwo"} ,null);
    });

    /**
     * first make sure all the regions exist
     */

    it("has all regions", function(done) {
      ectwo.regions.findAll(done.s(function(regions) {
        expect(regions.length).to.eql(ectwo.numRegions);
        done();
      }));
    });

    /**
     * then make sure that all regions are filterable 
     */

    it("can filter all US regions", function(done) {
      ectwo.regions.find({ name: /us-*/ }, done.s(function(regions) {
        expect(regions.length).to.eql(ectwo.numUsRegions);
        done();
      }));
    });

    /**
     */

    it("can filter all NON-US regions", function(done) {
      ectwo.regions.find({ name: {$ne: /us-*/ } }, done.s(function(regions) {
        expect(regions.length).to.eql(ectwo.numNonUsRegions);
        done();
      }));
    });

    /**
     */

    it("can find one region", function(done) {
      ectwo.regions.findOne({ name: /us-*/ }, done.s(function(region) {
        expect(region).to.be.an("object");
        expect(region).not.to.be(null);
        done();
      }));
    });
  });
}