################################################################################
#
# cairo-dock-plugins
#
################################################################################

CAIRO_DOCK_PLUGINS_VERSION = f1e7ae4482fc9cf28e8ed8c64c3a6bdc093579e4
CAIRO_DOCK_PLUGINS_SITE = $(call github,Cairo-Dock,cairo-dock-plug-ins,$(CAIRO_DOCK_PLUGINS_VERSION))
CAIRO_DOCK_PLUGINS_LICENSE = GPL-3.0+
CAIRO_DOCK_PLUGINS_LICENSE_FILES = COPYING
CAIRO_DOCK_PLUGINS_INSTALL_STAGING = YES

# Dépendances de base obligatoires
CAIRO_DOCK_PLUGINS_DEPENDENCIES = host-pkgconf cairo-dock libgl libgtk3 \
                                  dbus libxml2 libcurl

# Gestion des dépendances optionnelles (ajoutez-en selon vos besoins)
ifeq ($(BR2_PACKAGE_ALSA_LIB),y)
CAIRO_DOCK_PLUGINS_DEPENDENCIES += alsa-lib
endif

ifeq ($(BR2_PACKAGE_PULSEAUDIO),y)
CAIRO_DOCK_PLUGINS_DEPENDENCIES += pulseaudio
endif

ifeq ($(BR2_PACKAGE_LM_SENSORS),y)
CAIRO_DOCK_PLUGINS_DEPENDENCIES += lm-sensors
endif

$(eval $(cmake-package))
