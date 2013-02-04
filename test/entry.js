ectwo   = require("./init/ectwo");
expect  = require("expect.js"),
_       = require("underscore"),
outcome = require("outcome");


var NUM_US_REGIONS = 3,
NUM_REGIONS        = ectwo.allRegions.length,
NUM_NON_US_REGIONS = NUM_REGIONS - NUM_US_REGIONS,
AMI_UBUNTU_ID      = 


/**
 * first do a quick check against all loaded regions. Make sure
 * they're filterable
 */


describe("ECTwo Region Collection", function() {


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


  /**
   */

  it("can find one region", function(done) {
    ectwo.regions.findOne({ name: /us-*/ }, outcome.e(done).s(function(region) {
      expect(region).to.be.an("object");
      expect(region).not.to.be(null);
      done();
    }));
  })

});



/**
 * next, let's get dirty with ECTwo instances
 */

describe("ECTwo instances", function() {

  /**
   * Sanity check against the account to make sure instances aren't running
   */

  it("has NO registered instances", function(done) {
    ectwo.instances.findAll(function(err, servers) {
        expect(servers.length).to.eql(0);
        done();
    });
  });


  /**
   * TODO - run tests against ALL regions
   */

  describe("us-east-1", function() {

    var region, keyName = "test-key";

    it("can fetch us-east-1", function(done) {
      ectwo.regions.findOne({ name: "us-east-1" }, outcome.e(done).s(function(r) {
        expect(r.get("name")).to.be("us-east-1");
        region = r;
        done();
      }))
    });


    it("can create default key pair", function(done) {
      region.keyPairs.create(keyName, outcome.e(done).s(function(result) {
        expect(result).not.to.be(null);
        done();
      }));
    });


    it("can destroy default key pair", function(done) {
      region.keyPairs.findOne({ keyName: keyName }, outcome.e(done).s(function(result) {
        result.destroy(done);
      }));
    })


    it("can create an instance", function(done) {
      /*region.images.createInstance({
        imageId: "ami-3d4ff254"
      }, function() {

      })*/
      done();
    });

  });

});