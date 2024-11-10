################################################################################
#
# enigma
#
################################################################################

ENIGMA_VERSION = 936c6681aec1baf34c3094e318cda4957112fe6e
ENIGMA_SITE = $(call github,Enigma-Game,Enigma,$(ENIGMA_VERSION))
ENIGMA_LICENSE = GPL-2.0+
ENIGMA_LICENSE_FILES = COPYING

ENIGMA_DEPENDENCIES += host-automake host-autoconf host-libtool \
		       sdl2 sdl2_ttf sdl2_mixer sdl2_image xerces

define ENIGMA_RUN_AUTOCONF
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

ENIGMA_PRE_CONFIGURE_HOOKS += ENIGMA_RUN_AUTOCONF

define ENIGMA_DISABLE_DOC_INSTALL
        $(SED) 's/\(SUBDIRS = .*\) doc/\1/' \
                $(@D)/Makefile.am
endef
ENIGMA_POST_PATCH_HOOKS += ENIGMA_DISABLE_DOC_INSTALL

$(eval $(autotools-package))
