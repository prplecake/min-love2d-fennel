VERSION=0.1.0
NAME=change-me
URL=https://gitlab.com/alexjgriffith/min-love2d-fennel
AUTHOR="Alexander Griffith"
DESCRIPTION="Minimal setup for trying out Phil Hagelberg's fennel/love game design process."

LIBS := $(wildcard lib/*)
LUA := $(wildcard *.lua)
SRC := $(wildcard *.fnl)
OUT := $(patsubst %.fnl,%.lua,$(SRC))

LOVEFILE=releases/$(NAME)-$(VERSION).love

run: ; love $(PWD)

%.lua: %.fnl ; lua lib/fennel --compile --correlate $< > $@
clean: ; rm -rf $(OUT)

$(LOVEFILE): $(LUA) $(OUT) $(LIBS) assets
	mkdir -p releases/
	find $^ -type f | LC_ALL=C sort | env TZ=UTC zip -r -q -9 -X $@ -@

love: $(LOVEFILE)

# platform-specific distributables

REL="$(PWD)/love-release.sh" # https://p.hagelb.org/love-release.sh
FLAGS=-a "$(AUTHOR)" --description $(DESCRIPTION) \
	--love 11.2 --url $(URL) --version $(VERSION) --lovefile $(LOVEFILE)

releases/$(NAME)-$(VERSION)-x86_64.AppImage: $(LOVEFILE)
	cd appimage && ./build.sh 11.2 $(PWD)/$(LOVEFILE)
	mv appimage/game-x86_64.AppImage $@

releases/$(NAME)-$(VERSION)-macos.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -M
	mv releases/$(NAME)-macos.zip $@

releases/$(NAME)-$(VERSION)-win.zip: $(LOVEFILE)
	$(REL) $(FLAGS) -W32
	mv releases/$(NAME)-win32.zip $@

linux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
mac: releases/$(NAME)-$(VERSION)-macos.zip
windows: releases/$(NAME)-$(VERSION)-win.zip

# If you release on itch.io, you should install butler:
# https://itch.io/docs/butler/installing.html

uploadlinux: releases/$(NAME)-$(VERSION)-x86_64.AppImage
	butler push $^ technomancy/exo-encounter-667:linux
uploadmac: releases/$(NAME)-$(VERSION)-macos.zip
	butler push $^ technomancy/exo-encounter-667:mac
uploadwindows: releases/$(NAME)-$(VERSION)-win.zip
	butler push $^ technomancy/exo-encounter-667:windows

upload: uploadlinux uploadmac uploadwindows
