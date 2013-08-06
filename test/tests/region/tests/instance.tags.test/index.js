var async = require("async");
exports.require = ["region", "instance.test"];
exports.load = function(region, instance, loader, next) {
  describe("instance tags", function() {

    var tags = { key: "test", value: "hello-" + Date.now() };
    var ctags = JSON.parse(JSON.stringify(tags));


    after(function() {
      next(null, {
        tags: tags
      })
    });

    it("can be created", function(done) {
      instance.target.tags.create(ctags, done.s(function() {
        instance.target.tags.findOne(ctags, done.s(function(tag) {
          expect(tag).not.to.be(undefined);
          done();
        }));
      }));
    });


    it("can be used as a filter", function(done) {
      region.instances.findOne({ tags: ctags }, done.s(function(inst) {
        // expect(inst).to.be(instance.target);
        expect(inst).not.to.be(undefined);
        done();
      }));
    });


    it("value can be updated", function(done) {
      instance.target.tags.findOne(ctags, done.s(function(tag) {
        tag.setValue(ctags.value = "test-value", done);
      }));
    });

    it("new value can be used as a filter", function(done) {
      region.instances.findOne({ tags: ctags }, done.s(function(inst) {
        // expect(inst).to.be(instance.target);
        expect(inst).not.to.be(undefined);
        done();
      }));
    });

    it("old tags don't exist anymore", function(done) {
      region.instances.findOne({ tags: tags }, done.s(function(inst) {
        expect(inst).to.be(undefined);
        done();
      }));
    });

    //sanity
    it("can be used as a filter without a result", function(done) {
      region.instances.findOne({ tags: { key: "test", value: "wrong-value" } }, done.s(function(instance) {
        expect(instance).to.be(undefined);
        done();
      }));
    });

    it("can create many tags with the same key & still only get one key", function(done) {

      var tags = [
        { key: "key", value: "v1" },
        { key: "key", value: "v2" },
        { key: "key", value: "v3" },
        { key: "key", value: "v4" }
      ];

      async.forEachSeries(tags, function(tag, next) {
        instance.target.tags.create(tag, next);
      }, function() {
        instance.target.tags.find({ key: "key" }, done.s(function(tags){
          expect(tags.length).to.be(1);
          done();
        }));
      });
    });

    it("can remove all tags with a given key", function(done) {

      instance.target.tags.remove({ key: "key" }, done.s(function(){
        instance.target.tags.find({ key: "key" }, done.s(function(tags){
          expect(tags.length).to.be(0);
          done();
        }));
      }));
    })
  });
}