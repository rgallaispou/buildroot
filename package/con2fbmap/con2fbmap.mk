################################################################################
#
# con2fbmap
#
################################################################################

CON2FBMAP_VERSION = 1.0
# On indique que les sources sont locales (dans le sous-dossier src)
CON2FBMAP_SITE = package/con2fbmap/src
CON2FBMAP_SITE_METHOD = local

# Pas de licence spécifiée dans ton code, on met "Unknown" ou "Public Domain"
CON2FBMAP_LICENSE = Public Domain

define CON2FBMAP_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-o $(@D)/con2fbmap $(@D)/con2fbmap.c
endef

define CON2FBMAP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/con2fbmap $(TARGET_DIR)/usr/bin/con2fbmap
endef

$(eval $(generic-package))
