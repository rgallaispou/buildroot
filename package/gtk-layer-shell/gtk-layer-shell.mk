################################################################################
#
# gtk-layer-shell
#
################################################################################

GTK_LAYER_SHELL_VERSION = 0.10.0
GTK_LAYER_SHELL_SITE = https://github.com/wmww/gtk-layer-shell/archive/refs/tags
GTK_LAYER_SHELL_SOURCE = v$(GTK_LAYER_SHELL_VERSION).tar.gz
GTK_LAYER_SHELL_LICENSE = MIT
GTK_LAYER_SHELL_LICENSE_FILES = LICENSE
GTK_LAYER_SHELL_INSTALL_STAGING = YES
GTK_LAYER_SHELL_DEPENDENCIES = libgtk3 wayland wayland-protocols

# Utilise Meson
GTK_LAYER_SHELL_CONF_OPTS = -Dintrospection=false -Dvapi=false

$(eval $(meson-package))
