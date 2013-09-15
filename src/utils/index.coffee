module.exports = 
  cleanObj: (obj) ->

    for key of obj
      unless obj[key]
        delete obj[key]

    obj