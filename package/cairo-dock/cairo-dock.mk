################################################################################
#
# cairo-dock
#
################################################################################

CAIRO_DOCK_VERSION = 2527f4bad7f178a66742c22b6e478ea20e233869
CAIRO_DOCK_SITE = $(call github,Cairo-Dock,cairo-dock-core,$(CAIRO_DOCK_VERSION))
CAIRO_DOCK_LICENSE = GPL-3.0+
CAIRO_DOCK_LICENSE_FILES = COPYING
CAIRO_DOCK_INSTALL_STAGING = YES

CAIRO_DOCK_DEPENDENCIES = host-pkgconf libgl libgtk3 cairo libglib2 \
                          librsvg dbus wayland wayland-protocols \
			  libxkbcommon extra-cmake-modules \
			  gtk-layer-shell libglu libcurl dbus-glib

# Options pour activer Wayland nativement
CAIRO_DOCK_CONF_OPTS += \
	-Denable-wayland-support=YES

# Si vous avez XWayland et que vous voulez garder la compatibilité X11
ifeq ($(BR2_PACKAGE_XORG7),y)
CAIRO_DOCK_DEPENDENCIES += xlib_libX11 xlib_libXcomposite
CAIRO_DOCK_CONF_OPTS += -Denable-x11-support=YES
else
CAIRO_DOCK_CONF_OPTS += -Denable-x11-support=NO
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
CAIRO_DOCK_CONF_OPTS += -Denable-systemd-service=True
CAIRO_DOCK_DEPENDENCIES += systemd
else
CAIRO_DOCK_CONF_OPTS += -Denable-systemd-service=False
endif

ifeq ($(BR2_PACKAGE_WAYFIRE),y)
CAIRO_DOCK_DEPENDENCIES += json-c
endif

$(eval $(cmake-package))
