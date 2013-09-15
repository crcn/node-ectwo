ECTwo is a terminal utlity / node.js library that makes it incredibly easy to control your ec2 servers. 

## Features

- Ability to migrate images to other regions in the US
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
      "secret: "AWS_SECRET
    }
  }
}
```

`profiles` are used to help `ectwo` determine what account to use. 

### customizations

TODO


## Node usage