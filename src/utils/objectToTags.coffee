
###
###

module.exports = (obj) ->
  tags = []

  for key of obj
    tags.push { key: key, value: obj[key] }

  tags