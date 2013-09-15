


## API

### ec2 ectwo(config)

```javascript
var ec2 = ectwo({
  key: "KEY",
  secret: "SECRET"
});
```

### regions ec2.regions

Returns the regions collection

### region regions.find(query, next)

Finds a region 

```javascript
//find all US rgions
regions.find({ name: /us-*/ }, function (err, regions) {
  
});
```

### instances region.instances

returns the region instances collection

### instance instances.find(query, next)

same as region query

### instance.start(next)

starts an instance

### instance.stop(next)

stops an instance

### instance.terminate(next)

terminates an instance

### instance.restart(next)

restarts an instance

### image instance.createImage(next)

creates an image out of the instance


 

