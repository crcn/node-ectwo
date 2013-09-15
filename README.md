ECTwo is a terminal utlity / node.js library that makes it incredibly easy to control your ec2 servers. 

## Features

- Migrating images to other AWS regions.
- 
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

### customizations

TODO


## Node API

### ectwo(config)

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

### collections API

Ectwo generalizes collections across `images`, `instances`, `volumes`, `addresses`, `security groups`, and `key pairs`.

#### collection.find(query, cb)

Performs a search for an item. The query parameter expects a [mongodb query](https://github.com/crcn/sift.js)
