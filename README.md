### Features

- Migrating images & snapshots to different regions
- Start / Stop / Terminate instances
- assigning addresses to instances
- ability to launch spot requests
- creating keypairs
- creating / modifying security groups
- adding tags to images & instances

### Examples

See the tests directory.

### Testing

Make sure you have a testable account with EC2. I have one explictly for testing that doesn't have any production servers.

### Regions API

#### ectwo.regions.findOne(query, callback)



```javascript
//find ONE region that's anywhere in the U.S.
ectwo.regions.findOne({ name: /us-*/ }, function(err, region) {

  //us-west-1, or similar
  console.log(region.get("name"));
});
```

### Instances API

#### value instance.get(property)

returns a propertly value of the instance.

- `_id` - id of the instance
- `imageId` - the image id
- `state` - the state of the instance. Possible states:
  - `running` - instance is running
  - `pending` - initializing
  - `stopped` - instance is stopped
  - `terminated` - instance is terminated
  - `shutting-down` - instance is shutting down
  - `stopping` - instance is stopping
- `type` - the instance type (t1.micro, m1.medium, m1.small, etc.)
- `architecture` - i386, x86_64
- `tags` - instance tags (array)
  - `key` - tag key
  - `value` - tag value
  


#### instance.start(callback)

starts the instance

#### instance.reboot(callback)

restarts the instance

#### instance.stop(callback)

stops the instance

#### instance.destroy(callback)

destroys the instance

#### instance.createImage(callback)

creates an image out of the instance

```javascript
instance.createImage(function(err, image) {
  //do stuff with the image
})
```

#### instance.getImage(callback)

Fetches the image from `imageId`

````javascript
instance.getImage(function(err, image) {
  //do stuff with the image
});
````

#### instance.clone(callback)

clones the instance

#### instance.getAddress(callback)

returns the instance address

```javascript
instance.getAddress(function(err, address) {
    address.get("publicIp");
});
```

#### region.instances.find(query, callback)

Finds one instance

```javascipt

//do a search against all regions
ectwo.instances.findAll(function(err, instances) {
  instances.forEach(function(instance) {
    console.log(instance.get("region")); //us-west-1, ap-northeast-1, ...
  });
});

//find all running instances in this region
region.instances.find({ state: "running" }, function(err, instances) {
  
});
```

#### region.instances.findAll(callback)

fetches all instances 

#### region.instances.findOne(query, callback)

finds one instance

### Images API

#### value image.get(property)

- `_id` - id of the image
- `state` - image state - `pending`, or `completed`
- `name` - name of the image
- `type` - type of image
- `kernelId` - image kernel ID
- `platform` - `windows`, or `linux`
- `architecture` - i386, x86_64
- `descrption` - description of the image
- `tags` - image tags - same format as instances

#### image.createInstance(options, callback)

creates an instan

#### image.getOneSpotPricing(query, callback)

returns one spot pricing value

#### image.getSpotPricing(query, callback)

gets the spot pricing for the particular image

#### image.createSpotRequest(options, callback)

creates a new spot request

#### image.destroy(callback)

destroys the image

#### image.migrate(regions, callback)

migrates the image to the target regions

````javascript
ectwo.regions.findAll(function(err, regions) {
  var targetRegion = regions.shift();
  targetRegion.images.findAll(function(err, images) {

    images[0].migrate(regions, function(err, migrator) {
      migrator.on("progress", function(progress) {
        console.log(progress); //progress for migration 
      });

      migrator.on("complete", function(migratedImages) {
        //do stuff with the migrated images
      });
    });
  });
})
````

#### region.images.find(query, callback)

finds many images with the given query

### Address API

### address.getInstance(callback)

returns the target instance for the address

### address.associate(instance, callback)

assigns an address to an instance

### address.disassociate(callback)

disassociates an address from an instance

### address.destroy(callback)

### Snapshot API

### Security Group API

### Key Pair API

### Spot Requests API

### Tags PI


