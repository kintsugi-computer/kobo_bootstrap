OSNAME := $(shell uname -s)
ifeq ($(OSNAME), Darwin)
   GTAR := gtar
else
   GTAR := tar
endif

KoboRoot.tgz: $(shell find KoboRoot -type f)
	$(GTAR) -C KoboRoot --owner=root --group=root -zcf KoboRoot.tgz .
