CC ?= gcc
CFLAGS ?= -O3 -Wall
INSTALL_DEB ?= no
INSTALL_ROOT ?= /

.PHONY: clean install uninstall deb checkinstall

otraw2q:
	$(CC) -o otraw2q $(CFLAGS) otraw2q.c

clean:
	rm otraw2q

install: otraw2q
	install -v -s -m 755 otraw2q $(INSTALL_ROOT)usr/local/bin/

uninstall:
	rm /usr/local/bin/otraw2q

checkinstall:
	checkinstall -D --default --install=$(INSTALL_DEB) --fstrans=yes --pkgversion `git describe --tags | sed -e 's/^v//'` \
	--pkgname opentrigger-otraw2q --pkglicense MIT --maintainer 'info@acolono.com' --pkgsource 'https://github.com/acolono/opentrigger-otraw2q' \
	--pkgrelease '' make install
	
deb: VERSION = $(shell git describe --tags | sed -e 's/^v//')
deb: ARCH = $(shell dpkg --print-architecture)
deb: PKGNAME = opentrigger-otraw2q_$(VERSION)_$(ARCH)
deb:
	rm -rf $(PKGNAME) 2> /dev/null || true
	mkdir -p $(PKGNAME)/DEBIAN
	cp debian/* $(PKGNAME)/DEBIAN
	sed -i 's/__ARCH__/$(ARCH)/g' $(PKGNAME)/DEBIAN/control
	sed -i 's/__VERSION__/$(VERSION)/g' $(PKGNAME)/DEBIAN/control
	mkdir -p $(PKGNAME)/usr/local/bin/
	make install -e INSTALL_ROOT=$(PKGNAME)/
	fakeroot dpkg-deb --build $(PKGNAME)
	dpkg-deb -I $(PKGNAME).deb
	#-
	#- to install the package type:
	#- sudo dpkg -i $(PKGNAME).deb
	#-
	