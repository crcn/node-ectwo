var ectwo = require("ectwo");

ectwo.regions.findAll(function(err, regions) {
  regions[0].images.findAll(function(err, images) {
    images[0].migrate(regions[1], function(err, migrator) {
      migrator.on("progress", function(percentDone) {
        console.log(percentDone);
      }); 
      migrator.on("complete", function(migratedImage) {
        migratedImage.createInstance(function(err, instance) {
          //done!
        });
      })
    });
  })
});