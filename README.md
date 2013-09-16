
## Features

- Easily migrate images to other AWS regions
- Mongodb-like terminal utility 
- Ability to chain ec2 commands
- Built-in terminal helpers
  - ssh directly into instances via `instances().find(query).limit(1).ssh()`
  - ability to save key-pairs to disc via `keyPairs().create(name).save()`
  - make your own!
- Support for `key pair`, `instance`, `image`, `security group`, and `address` APIs


## TODO

- ability to clone instances
- spot requests
  - watch spot pricing

## Terminal Usage

```bash
Usage: ectwo [commands...] -c [config] -p [profile] -r [regions]

Options:
  -r  regions to use        
  -i  interactive             [default: false]
  -c  configuration location  [required]  [default: "/usr/local/etc/ectwo/conf"]
  -p  profile to use          [required]  [default: "default"]
```

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

Creating a new key-pair, and saving to disc:

```
$ ectwo -r us-east-1 "keyPairs().create('some-key').save()" ↩
------------------------------------

Profile: default
Regions: us-east-1

------------------------------------

us-east-1.keyPairs() 
us-east-1.keypairs.create("some-key") .. 2.79 s
us-east-1.some-key.save() 
[
  {
    "_id": "some-key",
    "name": "some-key",
    "region": "us-east-1",
    "fingerprint": "FINGERPRINT",
    "material": "MATERIAL"
  }
]
save keypair to /Users/craig/keys/us-east-1/some-key.pem
```

Finding all images across all regions:

```bash
$ ectwo -r us-east-1 "images().find()" ↩
------------------------------------

Profile: default
Regions: us-west-1, us-west-2, us-east-1, eu-west-1, sa-east-1, 
ap-southeast-1, ap-southeast-2, ap-northeast-1

------------------------------------

us-west-1.images() 
us-west-2.images() 
us-east-1.images() 
eu-west-1.images() 
sa-east-1.images() 
ap-southeast-1.images() 
ap-southeast-2.images() 
ap-northeast-1.images() 
us-west-1.images.find() 
us-west-2.images.find() 
us-east-1.images.find() 
eu-west-1.images.find() 
sa-east-1.images.find() 
ap-southeast-1.images.find() 
ap-southeast-2.images.find() 
ap-northeast-1.images.find() 
[
  {
    "_id": "ami-4d6f2724",
    "state": "available",
    "ownerId": "258306512238",
    "isPublic": "false",
    "region": "us-east-1",
    "name": "test",
    "type": "machine",
    "kernelId": "aki-825ea7eb",
    "platform": "linux",
    "architecture": "x86_64",
    "virtualizationType": "paravirtual",
    "tags": {
      "abbaa": "ff",
      "fds": "fds",
      "abba": "fdsfs",
      "fdsfs": "fdsfs"
    }
  }
]
```

You can also run `ectwo` in interactive mode by adding the `-i` flag. For example:

```bash
$ ectwo -r us-east-1 -i ↩
------------------------------------

Profile: default
Regions: us-east-1

------------------------------------

> addresses().find({ instanceId: undefined }).one().attach("i-b43313de")
us-east-1.addresses() 
us-east-1.addresses.find({}) 
us-east-1.54.225.244.40.attach("i-b43313de") .. 2.50 s
[
  {
    "_id": "54.225.244.40",
    "publicIp": "54.225.244.40",
    "domain": "standard",
    "region": "us-east-1",
    "instanceId": "i-b43313de"
  }
]
> instances().find({ _id: "i-b43313de" }).pluck("address")
us-east-1.instances() 
us-east-1.instances.find({"_id":"i-b43313de"}) 
us-east-1.i-b43313de.pluck("address") 
[
  {
    "address": "54.225.244.40"
  }
]
>
```

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

### Regions API

#### region.instances

instances collection

```javascript
//return all instances
region.instances.all(function(err, instances) {
  
});
```

#### region.images

images collection

#### region.addresses

addresses collection

#### region.keyPairs

keyPairs in a region

#### region.securityGroups

security groups in a region

### Instances API

#### instances.create(options, next)

creates one, or many instances

- `options` 
  - `imageId` - image ID to use
  - `count` - (optional) number of instances to create
  - `keyName` - (optional) key name to use
  - `securityGroupId` - (optional) security group ID to use
  - `flavor` - (optional) flavor of instance (t1.micro, m1.small, etc.)

```javascript
instances.create({ tags: { type: "redis" }, imageId: "ami-id" }, function(err, instance) {
  console.log(instance.get("state")); //running
});
```

#### value instance.get(property)

returns a propertly value of the instance.

- `_id` - id of the instance
- `imageId` - the image id
- `region` - the region this instance is in
- `state` - the state of the instance. Possible states:
  - `running` - instance is running
  - `pending` - initializing
  - `stopped` - instance is stopped
  - `terminated` - instance is terminated
  - `shutting-down` - instance is shutting down
  - `stopping` - instance is stopping
- `type` - the instance type (t1.micro, m1.medium, m1.small, etc.)
- `address` - assigned address
- `dnsName` - dns name
- `architecture` - i386, x86_64
- `tags` - instance tags (array)
  - `key` - tag key
  - `value` - tag value

#### instance.start(cb)

Starts an instance


```javascript
instance.start(function() {
  console.log(instance.get("state")); //running
});
```

#### instance.stop(cb)

Stops an instance

```javascript
instance.stop(function() {
  console.log(instance.get("state")); //stop
})
```

#### instance.restart(cb)

Restarts an instance

```javascript
instance.restart(function() {
  console.log(instance.get("state")); //running
})
```

#### instance.destroy(cb)

Destroys an instance


```javascript
instance.destroy(function() {
    console.log(instance.get("terminated")); 
});
```

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

#### instance.address(cb)

Returns the address assigned to the instance. If no address is assigned, the result will be null.

```javascript
instance.address(function(err, address) {
  console.log(address.get("publicIp"));
});
```

#### instance.image(cb)

returns the image associated with the instance

```javascript
instance.image(function(err, image) {
  console.log("image");
});
```

#### instance.resize(type, cb)

resizes an instance

```javascript
instance.resize("m1.small", function() {
  
});
```

### Images API


#### value image.get(property)

- `_id` - id of the image
- `region` - the region this image is in
- `state` - image state - `pending`, or `completed`
- `name` - name of the image
- `type` - type of image
- `kernelId` - image kernel ID
- `platform` - `windows`, or `linux`
- `architecture` - i386, x86_64
- `descrption` - description of the image
- `tags` - image tags - same format as instances

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

```javascript
region.addresses.create(function(err, address) {
  region.instances.findOne({ "tags.type": "site" }, function(err, instance) {
    address.attach(instance.get("_id"), function(err, result) {
    });
  });
});
```

#### value address.get(property)

- `_id` - id of the address
- `publicIp` - public IP
- `instanceId` - the instance this address is assigned to

#### address.attach(instanceId, cb)

associates an address with an instance

#### address.detach(cb)

disassociate an address with an instance

```javascript
instance.address(function(err, address) {
  address.detach(function(err) {
  });
});
```

### Key Pair API

#### keyPairs.create(name, cb)

Creates a new key pair.

```javascript
region.keyPairs.create("test", function(err, keyPair) {
  
  //put this somewhere safe
  console.log(keyPair.get("material")); 
});
```

#### value keyPair.get(property)

- `_id` - the key pair ID
- `name` - the key pair name
- `fingerPrint` - the key pair finger print
- `region` - the region this keyPair belongs to
- `material` - the key material - only returned on `keyPairs.create()`

### Security Group API

#### securityGroups.create(name, cb)

```javascript
region.securityGroups.create("something", function(){});
```

#### value securityGroup.get(property)

- `_id` - the security group ID
- `name` - the security group name
- `descrption` - the security group description
- `permissions` - security group permissions

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





