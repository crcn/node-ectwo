
/*

synchronizes regions based on the particular manifest
TODO:

- ability to assign route 53 server
- synchronizing security groups
- synchronizing images
- launch sequence - what servers to run and how many
- ability to assign an address

Should automatically migrate instances when a new one is detected - this is from
Identifying the createdAt timestamp added in the image tags
*/

//describes how the instances should be migrated
var manifest = {

  //source region to copy from
  source: "us-west-1",

  //all regions
  destination: "*",

  //images to copy
  images: [
    {
      name: "windows",
      search: {
        tags: {
          platform: "windows"
        }
      }
    },

    //front-facing website
    {
      search: {
        tags: {
          name: "website"
        }
      }
    },

    //provisions ec2 instances
    {
      search: {
        tags: {
          name: "provisioner"
        }
      }
    }
  ],

  //security groups
  securityGroups: {
    "default": {
      target: ["windows"]
      ports: [
        "8080-9000",
        "1935"
      ]
    }
  },

  //
  launch: [
    {
      target: ["windows"],
      count: 3,
      type: "t1.micro"
    },
    {
      target: "website",
      count: 1,
      type: "t1.micro"
    }
  ],

  addresses: [
    {
      target: ["website"],
      dns: "website.com"
    },
    {
      target: ["provisioner"],
      dns: "provision.website.com"
    }
  }
};


var synchronizer = syncRegions(manifest);

//called when the synchronizer kicks in
synchronizer.on("synchronizing", function() {

});


