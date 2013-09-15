ECTwo is a terminal utlity / node.js library that makes it incredibly easy to control your ec2 servers. 

## Features

- Ability to migrate images to other regions in the US
- Terminal Utility 
  - Ability to create custom terminal commands


## Terminal Usage

you'll first need to define your configuration file in `/usr/local/etc/ectwo/conf.js`. You'll notice that ectwo needs "profiles", these bits allows you to easily connect to different ec2 accounts. Here's an example config:

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



### customizations

TODO


## Node usage