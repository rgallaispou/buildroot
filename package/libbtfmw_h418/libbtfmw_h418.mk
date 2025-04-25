################################################################################
#
# libbtfmw-h418
#
################################################################################

LIBBTFMW_H418_VERSION = 1.0.3
LIBBTFMW_H418_SITE = https://bitbucket.org/4kopen/starkl/get
LIBBTFMW_H418_SOURCE = v$(LIBBTFMW_H418_VERSION).tar.bz2
LIBBTFMW_H418_LIB = $(subst _,-,$(LIBBTFMW_H418_NAME)).a

define LIBBTFMW_H418_EXTRACT_CMDS
	$(TAR) --no-anchored -xf $(LIBBTFMW_H418_DL_DIR)/$(LIBBTFMW_H418_SOURCE) \
		targetpack-20160812-3.tar.gz -O | \
	$(TAR) --strip-components=3 --no-anchored -xzf - $(LIBBTFMW_H418_LIB) \
		-O > $(STAGING_DIR)/usr/lib/$(LIBBTFMW_H418_LIB)
endef

define LIBBTFMW_H418_BUILD_CMDS
	$(TARGET_CROSS)objcopy --redefine-sym div64_u64=libbtfwm_div64_u64 \
		$(STAGING_DIR)/usr/lib/$(LIBBTFMW_H418_LIB)
	echo "CONFIG_TARGET_STIH418_B2264_LIBBTFMW_PATH=\"$(STAGING_DIR)/usr/lib\"" \
		> $(@D)/u-boot.fragment
endef

$(eval $(generic-package))
