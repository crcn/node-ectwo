ectwo  = require("./init/ectwo");
expect = require("expect.js"),
_      = require("underscore"),
outcome = require("outcome");


/**
 */


describe("ECTwo Region Collection", function() {

  var NUM_US_REGIONS = 3,
  NUM_REGIONS        = ectwo.allRegions.length,
  NUM_NON_US_REGIONS = NUM_REGIONS - NUM_US_REGIONS;

  /**
   * first make sure all the regions exist
   */

  it("has all regions", function(done) {
    ectwo.regions.findAll(outcome.e(done).s(function(regions) {
      expect(regions.length).to.eql(NUM_REGIONS);
      done();
    }));
  });


  /**
   * then make sure that all regions are filterable 
   */

  it("can filter all US regions", function(done) {
    ectwo.regions.find({ name: /us-*/ }, outcome.e(done).s(function(regions) {
      expect(regions.length).to.eql(NUM_US_REGIONS);
      done();
    }));
  });

  /**
   */

  it("can filter all NON-US regions", function(done) {
    ectwo.regions.find({ name: {$ne: /us-*/ } }, outcome.e(done).s(function(regions) {
      expect(regions.length).to.eql(NUM_NON_US_REGIONS);
      done();
    }));
  });
});