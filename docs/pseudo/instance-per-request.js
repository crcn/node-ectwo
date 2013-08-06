
/**

 */


function getInstance(userId, callback) {

  step(

    /**
     * first, find a bunch of free servers in different regions
     */

    function() {
      ectwo.instances.findOneFromEach({platform: "windows", tags: {$nin: [{ key: "userId", value: userId}], $all: [{key: "platform-version": value: "2003" }]}, state: {$in:["running","pending","stopped"]}}).exec(this);
    },

    /**
     * next, find the instance with the best ping
     */

    function(err, instances) {
      getInstanceWithBestPing(instances, this);
    },

    /**
     */

    function(err, instance) {
      callback(null, instance);
    }
  );
}


function getInstanceWithBestPing(instances, next) {
  var best, bestPing;
  async.forEach(instances, function(instance, next) {
    instance.getPing(function(err, ping) {
      if(!bestPing || ping.value > bestPing.value) {
        best = instance;
        bestPing = ping;
      }
      next();
    });
  }, function(err) {
    next(null, best);
  });
}