

ectwo   = require("./init/ectwo");
expect  = require("expect.js"),
_       = require("underscore"),
outcome = require("outcome"),
async = require("async");


var NUM_US_REGIONS = 3,
NUM_REGIONS        = ectwo.allRegions.length,
NUM_NON_US_REGIONS = NUM_REGIONS - NUM_US_REGIONS,
allRegions = ectwo.allRegions;


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


  var regionsToTest = allRegions;
  // regionsToTest = ["us-east-1", "us-west-1", "us-west2"];
  regionsToTest = ["us-east-1"];

  regionsToTest.forEach(function(regionName) {
    describe(regionName, runRegion(regionName));
  });

});



function runRegion(regionName) {
  return function() {
    
    var region;

    it("can fetch us-east-1", function(done) {
      ectwo.regions.findOne({ name: regionName }, outcome.e(done).s(function(r) {
        expect(r.get("name")).to.be(regionName);
        region = r;
        done();
      }))
    });

    if(false)
    describe("keypairs", function() {

      var keyName = "test-key";

      it("can be created", function(done) {
        region.keyPairs.create(keyName, outcome.e(done).s(function(result) {
          expect(result).not.to.be(null);
          done();
        }));
      });


      it("can be destroyed", function(done) {
        region.keyPairs.findOne({ keyName: keyName }, outcome.e(done).s(function(result) {
          result.destroy(done);
        }));
      });

      it("doesn't exist anymore", function(done) {
        region.keyPairs.findOne({ keyName: keyName }, outcome.e(done).s(function(result) {
          expect(result).to.be(undefined);
          done();
        }));
      });
    });
      
    if(false)
    describe("security groups", function() {

      var groupName = "test-group";

      it("can be created", function(done) {
        region.securityGroups.create(groupName, outcome.e(done).s(function(result) {
          expect(result).not.to.be(null);
          done()
        }));
      });

      it("can add ingress", function(done) {
        region.securityGroups.findOne({ groupName: groupName }, outcome.e(done).s(function(result) {
          result.authorizePorts(8080, outcome.e(done).s(function(result) {
            done();
          }));
        }));
      });

      it("can be destroyed", function(done) {
        region.securityGroups.findOne({ groupName: groupName }, outcome.e(done).s(function(group) {
          group.destroy(done);
        }));
      }); 
    });

    describe("instances", function() {

      var inst = null,
      imageId = "ami-3d4ff254",
      tags = { key: "test", value: "hello-" + Date.now() };

      it("can be created", function(done) {
        region.images.createInstance({
          imageId: imageId,
          flavor: "t1.micro"
        }, outcome.e(done).s(function(instance) {
          inst = instance;
          expect(inst).not.to.be(undefined);
          done();
        }));
      });

      it("can reload an instance", function(done) {
        inst.reload(done);
      });

      it("can add tags to an instance", function(done) {
        region.instances.findOne({ _id: inst.get("_id") }, outcome.e(done).s(function(instance) {
          instance.tags.create(tags, outcome.e(done).s(function() {
            instance.tags.findOne(tags, outcome.e(done).s(function(tag) {
              expect(tag).not.to.be(undefined);
              done();
            }));
          }));
        }));
      });


      it("can remove an instance tag", function(done) {
        region.instances.findOne({ _id: inst.get("_id") }, outcome.e(done).s(function(instance) {
          instance.tags.remove(tags, outcome.e(done).s(function() {
            instance.tags.findOne(tags, outcome.e(done).s(function(tag) {
              expect(tag).to.be(undefined);
              done();
            }));
          }));
        }));
      });

      it("can be destroyed", function(done) {
        region.instances.find({ imageId: imageId }, outcome.e(done).s(function(instances) {
          expect(instances.length).not.to.be(0);
          async.forEach(instances, function(instance, next) {
            instance.destroy(next);
          }, done);
        }));
      });

    });

    
  }
}