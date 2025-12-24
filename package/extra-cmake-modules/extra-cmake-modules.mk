################################################################################
#
# extra-cmake-modules
#
################################################################################

EXTRA_CMAKE_MODULES_VERSION = 6.21.0
EXTRA_CMAKE_MODULES_SITE = $(call github,KDE,extra-cmake-modules,v$(EXTRA_CMAKE_MODULES_VERSION))
EXTRA_CMAKE_MODULES_LICENSE = BSD-3-Clause
EXTRA_CMAKE_MODULES_LICENSE_FILES = COPYING-CMAKE-SCRIPTS
EXTRA_CMAKE_MODULES_INSTALL_STAGING = YES

# ECM n'a pas de dépendances car ce ne sont que des fichiers texte .cmake
EXTRA_CMAKE_MODULES_DEPENDENCIES = host-cmake

# On désactive les tests et la doc pour aller plus vite
EXTRA_CMAKE_MODULES_CONF_OPTS += -DBUILD_TESTING=OFF -DBUILD_HTML_DOCS=OFF -DBUILD_MAN_DOCS=OFF

$(eval $(cmake-package))
$(eval $(host-cmake-package))
