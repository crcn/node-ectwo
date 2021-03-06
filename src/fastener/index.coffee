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
    help: "reload()"
    type: "instances"
    call: (next) -> _reload @, next 
  create:
    type: "instance"
}

fastener.add "images", {
  find: 
    type: "image"
  reload:
    type: "images"
    call: (next) -> _reload @, next 
}


fastener.add "volumes", {
  create:
    type: "volume"
  find: 
    type: "volume"
  reload:
    type: "volumes"
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
  create:
    type: "address"
}

fastener.add "securityGroups", {
  find: 
    type: "securityGroup"
  reload:
    type: "securityGroups"
    call: (next) -> _reload @, next 
  create:
    type: "securityGroup"
}

fastener.add "snapshots", {
  find: 
    type: "snapshot"
  reload:
    type: "snapshots"
    call: (next) -> _reload @, next 
  create:
    type: "snapshot"
}

fastener.add "zones", {
  find: 
    type: "zone"
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
  create:
    type: "keyPair"
}

  

fastener.add "region", {

  instances:
    type: "instances"
    call: (next) -> _load @instances, next

  images: 
    type: "images"
    call: (next) -> _load @images, next

  volumes:
    type: "volumes"
    call: (next) -> _load @volumes, next

  addresses:
    type: "addresses"
    call: (next) -> _load @addresses, next

  securityGroups: 
    type: "securityGroups"
    call: (next) -> _load @securityGroups, next

  zones: 
    type: "zones"
    call: (next) -> _load @zones, next

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
  tag:
    type: "image"
  migrate:
    type: "image"
}

fastener.add "volume", {
  destroy:
    type: "volume"
  attach:
    type: "volume"
  detach:
    type: "volume"
  createSnapshot: 
    type: "snapshot"
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
  tag: 
    type: "instance"
  address:
    type: "address"
  image:
    type: "image"
  resize:
    type: "instance"
  update:
    type: "instance"
  status:
    type: "object" 
  volumes: 
    type: "volume"
}

fastener.add "keyPair", {
  destroy:
    type: "keyPair"
}

fastener.add "snapshot", {
  destroy:
    type: "snapshot"
  createVolume:
    type: "volume"
}

fastener.add "securityGroup", {
  authorize:
    type: "securityGroup"
  revoke:
    type: "securityGroup"
  destroy:
    type: "securityGroup"
}

fastener.add "address", {
  attach: 
    type: "address"
  detach:
    type: "address"
  destroy: 
    type: "address"
}

fastener.add "zone", {

}

fastener.all 
  help:
    type: "help",
    onCall: (target) ->
      for name of @methods
        console.log " ", @methods[name].help ? name + "()"
    call: (next) -> next()
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


