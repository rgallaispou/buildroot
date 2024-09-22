################################################################################
#
# wayfire
#
################################################################################

WAYFIRE_VERSION = v0.10.1
WAYFIRE_SITE = https://github.com/WayfireWM/wayfire
WAYFIRE_SITE_METHOD = git
WAYFIRE_GIT_SUBMODULES = YES
WAYFIRE_LICENSE = MIT
WAYFIRE_LICENSE_FILES = LICENSE
WAYFIRE_DEPENDENCIES = host-pkgconf wlroots glm yyjson cairo pango
WAYFIRE_INSTALL_STAGING = YES
WAYFIRE_CONF_OPTS = \
	-Dwerror=false

define WAYFIRE_USERS
	wayfire -1 wayfire -1 * /home/wayfire /bin/sh seat,audio,video Wayfire user
endef

$(eval $(meson-package))
