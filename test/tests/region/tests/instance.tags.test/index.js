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
        console.log(instance.target.get("_id"));
        if(inst) console.log(inst.get("_id"));
        expect(inst).to.be(instance.target);
        done();
      }));
    });

    it("key can be updated", function(done) {
      instance.target.tags.findOne(ctags, done.s(function(tag) {
        tag.setKey(ctags.key = "test2", done);
      }));
    });

    //check incase the instance hasn't reloaded properly
    it("new key can be used as a filter", function(done) {
      region.instances.findOne({ tags: ctags }, done.s(function(inst) {
        expect(inst).to.be(instance.target);
        done();
      }));
    });

    //now do a hard reload
    it("can reload the target", function(done) {
      instance.target.reload(done);
    });

    //sanity check. make sure the key can still be filtered
    it("new key can STILL be used as a filter", function(done) {
      region.instances.findOne({ tags: ctags }, done.s(function(inst) {
        expect(inst).to.be(instance.target);
        done();
      }));
    });

    it("value can be updated", function(done) {
      instance.target.tags.findOne(ctags, done.s(function(tag) {
        tag.setValue(ctags.value = "test-value", done);
      }));
    });

    it("new value can be used as a filter", function(done) {
      //console.log(ctags);
      //console.log(instance.target.get())
      region.instances.findOne({ tags: ctags }, done.s(function(inst) {
        expect(inst).to.be(instance.target);
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
  });
}