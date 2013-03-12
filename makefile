all:
	coffee -o lib -c src	

clean:
	rm -rf lib


test: 
	mocha test/index.js --timeout 99999

	
