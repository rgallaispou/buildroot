################################################################################
#
# wayvnc
#
################################################################################

WAYVNC_VERSION = 0596d1135ca04bb793218846475572f6ea93d899
WAYVNC_SITE = $(call github,any1,wayvnc,$(WAYVNC_VERSION))
WAYVNC_LICENSE = ISC
WAYVNC_LICENSE_FILES = COPYING
WAYVNC_DEPENDENCIES = aml neatvnc jansson wayland wayland-protocols pixman libxkbcommon
WAYVNC_CONF_OPTS = -Dman-pages=disabled

$(eval $(meson-package))
