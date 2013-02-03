var ectwo = require("../../"),
config    = require("../config");

module.exports = ectwo(config.aws);
module.exports.allRegions = ectwo.regions;