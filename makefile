all:
	coffee -o lib -c src	

clean:
	rm -rf lib

all-watch:
	coffee -o lib -cw src
	

test: 
	mocha test/index.js --timeout 99999

	
