/**
 vars:

 defined:

 - instances / user - explicit, or calculated
    - based on CPU usage

 - calculator
    - calculation method used to find N people needed to run server
      - social network?
      - cpu load?

 used:

 - reponse time
    - time it takes to calculate a response
 
 returned:

 - number of servers needed based on:
    - response time
    - instances / user

 */

function predict()


var predictor = predict({
  loadWatcher: predictor.explicit(1),
  calculator: predictor.social()
});


predictor.on("update", function() {
  console.log(predictor.needed);
});

var getInstance = predictor.time(function(userId, callback) {

});

getInstance("")