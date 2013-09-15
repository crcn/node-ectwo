exports.load = () ->
  defaultKeyPath: (region, name) ->
    "~/keys/#{region}/#{name}.pem"