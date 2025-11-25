################################################################################
#
# wayfire-plugins-extra
#
################################################################################

WAYFIRE_PLUGINS_EXTRA_VERSION = v0.10.0
WAYFIRE_PLUGINS_EXTRA_SITE = https://github.com/WayfireWM/wayfire-plugins-extra
WAYFIRE_PLUGINS_EXTRA_SITE_METHOD = git
WAYFIRE_PLUGINS_EXTRA_GIT_SUBMODULES = YES
WAYFIRE_PLUGINS_EXTRA_LICENSE = MIT
WAYFIRE_PLUGINS_EXTRA_LICENSE_FILES = LICENSE
WAYFIRE_PLUGINS_EXTRA_DEPENDENCIES = host-pkgconf wlroots cairo wayfire boost
WAYFIRE_PLUGINS_EXTRA_INSTALL_STAGING = YES
WAYFIRE_PLUGINS_EXTRA_CONF_OPTS = \
	-Dwerror=false \
	-Denable_wayfire_shadows=true \
	-Denable_filters=true \
	-Denable_pixdecor=true \
	-Denable_focus_request=true

$(eval $(meson-package))
