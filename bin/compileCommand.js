module.exports = function(command) {
  return new Function("return (function(ectwo){ with(ectwo){ return "+command+"; } })")();
}