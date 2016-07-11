CC ?= gcc
CFLAGS ?= -O3 -Wall

default: otraw2q

otraw2q:
	$(CC) -o otraw2q $(CFLAGS) otraw2q.c

clean:
	rm otraw2q

install: otraw2q
	install -s -m 755 -o root -g root otraw2q /usr/local/bin/

uninstall:
	rm /usr/local/bin/otraw2q

print:
	echo CC=$(CC) CFLAGS=$(CFLAGS)
