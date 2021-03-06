all: bootstrap bankersbox combinedjs

site: all
	rm -rf _site
	mkdir -p _site/{css,js,img}
	cp html/index.html _site
	cp js/coffee/combined.js _site/js/application.js
	cp css/bootstrap/bootstrap/img/{glyphicons-halflings.png,glyphicons-halflings-white.png} _site/img
	cp css/bootstrap/bootstrap/js/bootstrap.min.js _site/js
	cp css/bootstrap/bootstrap/css/{bootstrap.css,bootstrap-responsive.css,bootstrap.min.css,bootstrap-responsive.min.css} _site/css
	cp js/Bankersbox/bankersbox.min.js _site/js
	cp js/tappable/source/tappable.js _site/js

sitemin: site combinedjsmin
	cp js/coffee/combined.min.js _site/js/application.js

clean:
	rm -rf _site
	rm -f js/coffee/*.js
	pushd css/bootstrap && make clean && popd
	pushd js/BankersBox && make clean && popd

###
### Combined JS assets
###

combinedjs: js/coffee/combined.js

js/coffee/combined.js: js/coffee/cards.coffee js/coffee/app.coffee
	coffee -j -c -p js/coffee/cards.coffee js/coffee/app.coffee > js/coffee/combined.js

combinedjsmin: js/coffee/combined.min.js

js/coffee/combined.min.js: js/coffee/combined.js
	java -jar compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js js/coffee/combined.js > js/coffee/combined.min.js

###
### Cards dependencies
###

cards: js/coffee/cards.js

js/coffee/cards.js: js/coffee/cards.coffee
	coffee -c js/coffee/cards.coffee

cardsmin: js/coffee/cards.min.js

js/coffee/cards.min.js: js/coffee/cards.js
	@echo "Minifying cards.js..."
	#curl -d output_format=text -d output_info=compiled_code -d compilation_level=SIMPLE_OPTIMIZATIONS --data-urlencode js_code@js/coffee/cards.js http://closure-compiler.appspot.com/compile > js/coffee/cards.min.js 2> /dev/null
	java -jar compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js js/coffee/cards.js > js/coffee/cards.min.js
	@echo "Done."

appjs: js/coffee/app.js

js/coffee/app.js: js/coffee/app.coffee
	coffee -c js/coffee/app.coffee

appjsmin: js/coffee/app.min.js

js/coffee/app.min.js: js/coffee/app.js
	@echo "Minifying app.js"
	#curl -d output_format=text -d output_info=compiled_code -d compilation_level=SIMPLE_OPTIMIZATIONS --data-urlencode js_code@js/coffee/app.js http://closure-compiler.appspot.com/compile > js/coffee/app.min.js 2> /dev/null
	java -jar compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js js/coffee/app.js > js/coffee/app.min.js
	@echo "Done."

###
### Bootstrap dependencies
###

bootstrap:
	pushd css/bootstrap && make bootstrap && popd

###
### Bankersbox dependencies
###

bankersbox:
	pushd js/BankersBox && make min && popd

###
### Deploy
###

deploy: sitemin
	pushd _site && s3cmd sync . ${BRIDGE_S3_BUCKET} && popd


.PHONY: all clean deploy bootstrap bankersbox cards cardsmin combinedjs combinedjsmin site sitemin