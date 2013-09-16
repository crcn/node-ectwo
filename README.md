ECTwo is a terminal utlity / node.js library that makes it incredibly easy to control your ec2 servers. 

## Features

- Migrating images to other AWS regions.
- Terminal Utility 
  - Ability to create custom terminal commands



## Terminal Usage

You'll first need to define your configuration file in `/usr/local/etc/ectwo/conf.js`. Here's a template:

```javascript
module.exports = {
  "profiles": {
    "default": {
      "regions": ["us-east-1", "us-west-1"],
      "key": "AWS_KEY",
      "secret": "AWS_SECRET"
    },
    "another-profile": {
      "key": "AWS_KEY",
      "secret": "AWS_SECRET"
    }
  }
}
```

`profiles` are used to help `ectwo` determine what account to use. 

### Examples

Migrating Images to another


## Node API

#### ectwo(config)

- `config` - configuration
  - `regions` - (optional) - regions to use
  - `key`     - AWS key
  - `secret`  - AWS secret

```javascript
var ectwo = require("ectwo")({
  regions: ["us-east-1"],
  key: "AWS_KEY",
  secret: "AWS_SECRET"
});
```

### Collections API

Ectwo generalizes collections across `images`, `instances`, `volumes`, `addresses`, `security groups`, and `key pairs`.

#### collection.findOne(query, cb)

Performs a search for an item. The query parameter expects a [mongodb query](https://github.com/crcn/sift.js).

```javascript

//find all US regions
ectwo.regions.findOne({ name: "us-east-1" }, function (err, region) {
  
  //find all staging instances
  region.instances.find({ "tags.cluster": "staging" }, function(err, instances) {
    console.log(instances);
  });
});
```

#### collection.find(query, cb)

Finds multiple items

#### collection.wait(query, cb)

Wait for the query condition to be met before calling `cb`. 

#### collection.reload(cb)

reloads the collection. Collections are cached by default.

### Instances API

#### instances.create(options, next)

creates one, or many instances

- `options` 
  - `imageId` - image ID to use
  - `count` - (optional) number of instances to create
  - `keyName` - (optional) key name to use
  - `securityGroupId` - (optional) security group ID to use
  - `flavor` - (optional) flavor of instance (t1.micro, m1.small, etc.)

#### instance.start(cb)

Starts an instance

#### instance.stop(cb)

Stops an instance

#### instance.restart(cb)

Restarts an instance

#### instance.destroy(cb)

Destroys an instance

#### instance.createImage(cb)

Creates an image out of the instance

#### instance.tag(key, value, cb)

Creates / deletes / updates tag.

```javascript

//create
instance.tag("type", "mongodb", function() {
  
  //update
  instance.tag({ type: "another type" }, function() {
  
    //delete
    instance.tag("type", undefined, function() {
    });
  });
});
```

### Images API

#### image.migrate(regions, cb)

Migrates the image to another region

```javascript
images.findOne({ _id: "ami-id" }, function(err, image) {
  image.migrate(["us-west-1", "us-west-2"], function(err, images) {
  });
});
```

#### image.createInstance(options, cb)

Creates an instance out of the image. Options are the same as `instance.create`.

### Addresses API

#### addresses.create(cb)

creates a new address

#### address.associate(instanceId, cb)

associates an address with an instance

#### address.disassociate(cb)

disassociate an address with an instance


### Key Pair API

#### keyPairs.create(name, cb)

Creates a new key pair.

```javascript
region.keyPairs.create("test", function(err, keyPair) {
  
  //put this somewhere safe
  console.log(keyPair.get("material")); 
});
```

### Security Group API

#### securityGroups.create(name, cb)

```javascript
region.securityGroups.create("something", function(){});
```

#### securityGroup.authorize(portOrOptions, cb);

```javascript
securityGroup.authorize(4343, function(){});
securityGroup.authorize({ from: 8080, to: 8090 }, function(){});
```

#### securityGroup.revoke(portOrOptions, cb);

Opposite of `authorize`.


## Chaining

ectwo also supports chaining. Here are a few examples:

```javascript

//find ALL images, migrate them to us-west-2, then launch them
ectwo.chain().regions().find().images().find().migrate(["us-west-2"]).createInstance({ flavor: "m1.small" });

//stop redis instances
ectwo.chain().regions().find({ "tags.type": "redis" }).instances().stop()
```





