default: otraw2q

otraw2q:
	gcc -o otraw2q -O3 -Wall otraw2q.c

clean:
	rm otraw2q

install: otraw2q
	install -s -m 755 -o root -g root otraw2q /usr/local/bin/

uninstall:
	rm /usr/local/bin/otraw2q
