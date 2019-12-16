#---------------------------------------------------------------
# project definitions
#---------------------------------------------------------------
project = hmi-detector-3000

#---------------------------------------------------------------
# creation order
#---------------------------------------------------------------
GPL_TARGETS = toolchain%step1 linux uClibc toolchain%step2 busybox firmware-gpl
GPL_SUBDIRS = toolchain linux uClibc busybox firmware-gpl

gpl-make-all = $(foreach target,$(GPL_TARGETS),gpl-make-all-$(target).done)

#-------------------------------------
# show targets
#-------------------------------------
all : # "show possible targets"
	@echo "POSSIBLE TARGETS:"
	@perl -ne 'm/^\s*([-_a-z]+)\s*:[^\x23]*(\x23\s*"(.*)")?/ && printf "%-20s : %s\n",$$1,$$3;' Makefile

gpl-all : $(gpl-make-all)	# "Rebuild all for GPL-Version Firmware"


maketarget-toolchain%step1=all-step1
maketarget-toolchain%step2=all-step2
maketarget-uClibc = all install postinstall

gpl-make-all-%.done :
	rm -f .done
	mkdir -vp build
	[ -d build/$(project)-$(word 1,$(subst %, ,$*)) ] || tar -C build -xjf $(project)-$(word 1,$(subst %, ,$*)).tar.bz2
	( cd build/$(project)-$(word 1,$(subst %, ,$*)) && make $(maketarget-$*) 2>&1 && touch ../../.done ) | tee build/make-$*.log
	rm .done
#	touch $@

clean: $(foreach subdir,$(GPL_SUBDIRS),clean-$(subdir))
	-rm -f $(all-targets) *.log

clean-% :
	-cd $(project)-$* && make clean

distclean: $(foreach subdir,$(GPL_SUBDIRS),distclean-$(subdir))
	-rm -f *.done *.log
	-rm -rf local

distclean-% :
	-cd $(project)-$* && make distclean
