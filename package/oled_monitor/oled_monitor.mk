################################################################################
#
# oled_monitor
#
################################################################################

OLED_MONITOR_VERSION = 1.0
OLED_MONITOR_SITE = package/oled_monitor/src
OLED_MONITOR_SITE_METHOD = local

# Dépendance CRITIQUE : on force Buildroot à construire ncurses avant
OLED_MONITOR_DEPENDENCIES = ncurses

# On passe les variables standards (CC, CFLAGS, LDFLAGS) au Makefile
define OLED_MONITOR_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define OLED_MONITOR_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/oled_monitor $(TARGET_DIR)/usr/bin/oled_monitor
endef

$(eval $(generic-package))
