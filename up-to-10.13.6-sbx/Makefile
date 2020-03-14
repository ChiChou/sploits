payload: template prepare escape.m
	cc -framework ApplicationServices -framework Foundation \
		-bundle escape.m -o assets/libsbesc.bundle

template:
	xxd -i Info.plist content.gen.h
	xxd -i main.html >> content.gen.h
	xxd -i Default.png >> content.gen.h

prepare:
	mkdir -p assets