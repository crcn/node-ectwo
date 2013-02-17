var ectwo = require("../../../"),
config    = require("./config"),
sift      = require("sift");

exports.plugin = function() {
  var ec2 = ectwo(config.aws);
  ec2.allRegions = ectwo.regions;

  ec2.numUsRegions    = sift(/us-*/, ec2.allRegions).length;
  ec2.numRegions      = ec2.allRegions.length;
  ec2.numNonUsRegions = ec2.numRegions - ec2.numUsRegions;

  return ec2;
}