### Features

- Migrate 



### Examples

Let's assume this is at the top of your node.js doc:

```javascript
var ectwo = require("ectwo")({ key: "<KEY>", secret: "<SECRET>" });
```

#### Create & migrate an instance

```javascript
ectwo.servers.findOne({ _id: "server-id" }, function(err, server) {
	server.createAMI(function(err, ami) {
		var info = ami.migrate(["sao-paulo", "us-west", "tokyo"]);
		info.on("progress", function(info) {

		});
		info.on("complete", function() {
			//done!
		});
	});
});
```



### API


