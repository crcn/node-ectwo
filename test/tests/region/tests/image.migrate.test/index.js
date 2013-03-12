var async = require("async")

exports.require = ["region", "image.test"];
exports.load = function(region, image, loader, next) {
  describe("image migration", function() {

    var img, tregions, search = { name: { $ne: region.get("name") }};

    before(function() {
      img = image.target;
    });

    after(function() {
      next(null, {
        region: tregions
      });
    });

    it("can migrate an image to another", function(done) {
      region.all.regions.find(search, done.s(function(regions) {
        expect(tregions = regions).not.to.be(undefined);
        img.migrate(regions, done.s(function(migrators) {
          migrators.on("error", done);
          migrators.on("complete", function(image) {
            expect(image).not.to.be(undefined);
            done();
          })
        }));
      }));
    });

    it("all regions have images with vanilla flavored tags", function(done) {
      async.forEach(tregions, function(region, next) {
        region.images.find({ tags: { key: "flavor", value: "vanilla" } }, outcome.e(next).s(function(images) {
          expect(images.length).not.to.be(0);
          next();
        }))
      }, done);
    });


    it("all regions can start an instance", function(done) {
      async.forEach(tregions, function(region, next) {
        region.images.findAll(outcome.e(next).s(function(images) {
          images[0].createInstance({ flavor: "t1.micro" }, outcome.e(next).s(function(instance) {
            expect(instance).not.to.be(undefined);
            next();
          }));
        }));
      }, done);
    });

    it("all regions have at least one running instance", function(done) {
      async.forEach(tregions, function(region, next) {
        region.instances.findAll(outcome.e(next).s(function(instances) {
          expect(instances.length).not.to.be(0);
          next();
        }));
      }, done);
    });

    it("all regions can remove running instances", function(done) {
      async.forEach(tregions, function(region, next) {
        region.instances.findAll(outcome.e(next).s(function(instances) {
          async.forEach(instances, function(instance, next) {
            instance.destroy(next);
          }, next);
        }));
      }, done);
    });


    it("all regions can remove the ported image", function(done) {
      async.forEach(tregions, function(region, next) {
        region.images.findAll(outcome.e(next).s(function(images) {
          async.forEach(images, function(image, next) {
            image.destroy(next);
          }, next);
        }))
      }, done);
    });

    it("all regions don't have anymore ported images", function(done) {
      async.forEach(tregions, function(region, next) {
        region.images.findAll(outcome.e(next).s(function(images) {
          expect(images.length).to.be(0);
          next();
        }))
      }, done);
    });


    it("all regions can remove snapshots", function(done) {
      async.forEach(tregions, function(region, next) {
        region.snapshots.findAll(outcome.e(next).s(function(snapshots) {
          async.forEach(snapshots, function(snapshot, next) {
            snapshot.destroy(next);
          }, next);
        }));
      }, done);
    }); 
  });
}