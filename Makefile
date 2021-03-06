.PHONY = zip rpm clean buildout install

version=`cat version.txt`
python=python2.7
lasttag=`git describe --abbrev=0 --tags`

clean:
	rm -rf bin lib include eggs local


prerelease:
	prerelease --no-input -v

release:
	release --no-input -v

postrelease:
	postrelease --no-input -v

venv:
	@if test -f bin/${python}; then echo "Virtualenv already created"; \
				else virtualenv -p ${python} . ; fi
bootstrap:
	./bin/${python} bootstrap.py -c both.cfg

buildout:
	./bin/buildout -Nt 5 -c both.cfg

install: venv bootstrap buildout

zip: venv bootstrap buildout
	rm -rf eggs-plonecirb
	mv eggs eggs-plonecirb
	tar -zcf eggs-plonecirb-${version}-${python}.tar.gz eggs-plonecirb/
	mv eggs-plonecirb eggs

upload: zip
	swift -U plone:backup -A https://s.irisnet.be/auth/v1.0/ -K 66031d89fa upload PloneCirb eggs-plonecirb-${version}-${python}.tar.gz
 
update: prerelease release upload postrelease

rpm:
	swift -U plone:backup -A https://s.irisnet.be/auth/v1.0/ -K 66031d89fa download PloneCirb eggs-plonecirb-${lasttag}-${python}.tar.gz
	sudo alien --to-rpm -v eggs-plonecirb-${lasttag}-${python}.tar.gz
