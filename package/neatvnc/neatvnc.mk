################################################################################
#
# neatvnc
#
################################################################################

NEATVNC_VERSION = 9648e52ee8a8a06867c82c9d85e3acb367922bc1
NEATVNC_SITE = $(call github,any1,neatvnc,$(NEATVNC_VERSION))
NEATVNC_LICENSE = ISC
NEATVNC_LICENSE_FILES = COPYING
NEATVNC_INSTALL_STAGING = YES
NEATVNC_DEPENDENCIES = aml pixman libdrm zlib

# Options pour les performances (JPEG et TLS)
ifeq ($(BR2_PACKAGE_LIBJPEG),y)
NEATVNC_DEPENDENCIES += libjpeg
endif

ifeq ($(BR2_PACKAGE_GNUTLS),y)
NEATVNC_DEPENDENCIES += gnutls
endif

$(eval $(meson-package))
