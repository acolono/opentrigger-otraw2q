CC ?= gcc
CFLAGS ?= -O3 -Wall
INSTALL_DEB ?= no

.PHONY: clean install uninstall deb

otraw2q:
	$(CC) -o otraw2q $(CFLAGS) otraw2q.c

clean:
	rm otraw2q

install: otraw2q
	install -v -m 755 otraw2q /usr/local/bin/

uninstall:
	rm /usr/local/bin/otraw2q

deb:
	checkinstall -D --default --install=$(INSTALL_DEB) --fstrans=yes --pkgversion `git describe --tags | sed -e 's/^v//'` \
	--pkgname opentrigger-otraw2q -A all --pkglicense MIT --maintainer 'info@acolono.com' --pkgsource 'https://github.com/acolono/opentrigger-otraw2q' \
	--pkgrelease '' make install
