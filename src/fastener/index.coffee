fastener = require("fasten")()

fastener.add "ectwo", {
  regions:
    type: "regions"
    call: (next) ->
      _load @regions, next
}

_load = (collection, next) ->
  collection.load {}, () ->
    next null, collection

_reload = (collection, next) ->
  collection.reload {}, () ->
    next null, collection

fastener.add "regions", {
  find: 
    type: "region"
  reload:
    type: "region"
}

fastener.add "instances", {
  find: 
    type: "instance"
  reload:
    type: "instances"
    call: (next) -> _reload @, next 
}

fastener.add "images", {
  find: 
    type: "image"
  reload:
    type: "images"
    call: (next) -> _reload @, next 
}

fastener.add "object", {

}

fastener.add "addresses", {
  find: 
    type: "address"
  reload:
    type: "addresses"
    call: (next) -> _reload @, next 
}

fastener.add "securityGroups", {
  find: 
    type: "securityGroup"
  reload:
    type: "securityGroups"
    call: (next) -> _reload @, next 
}

fastener.add "snapshots", {
  find: 
    type: "snapshot"
  reload:
    type: "snapshots"
    call: (next) -> _reload @, next 
}

fastener.add "spotRequests", {
  find: 
    type: "spotRequest"
  reload:
    type: "spotRequests"
    call: (next) -> _reload @, next 
}

fastener.add "keyPairs", {
  find: 
    type: "keyPair"
  reload:
    type: "keyPairs"
    call: (next) -> _reload @, next 
}

  

fastener.add "region", {

  instances:
    type: "instances"
    call: (next) -> _load @instances, next

  images: 
    type: "images"
    call: (next) -> _load @images, next

  addresses:
    type: "addresses"
    call: (next) -> _load @addresses, next

  securityGroup: 
    type: "securityGroups"
    call: (next) -> _load @securityGroups, next

  snapshots:
    type: "snapshots"
    call: (next) -> _load @snapshots, next

  spotRequests:
    type: "spotRequests"
    call: (next) -> _load @snapshots, next

  keyPairs:
    type: "keyPairs"
    call: (next) -> _load @keyPairs, next

}

fastener.add "image", {
  createInstance:
    type: "instance"
  destroy:
    type: "image"
}

fastener.add "instance", {
  start: 
    type: "instance"
  stop: 
    type: "instance"
  restart: 
    type: "instance"
  destroy:
    type: "instance"
  createImage:
    type: "image"
}


fastener.all 
  pluck:
    type: "object"
    call: () ->
      props = Array.prototype.slice.call arguments, 0
      next  = props.pop()

      data = {}
      for key in props
        data[key] = @get(key)

      next null, data

module.exports = fastener


