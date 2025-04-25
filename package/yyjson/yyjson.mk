################################################################################
# yyjson
################################################################################

YYJSON_VERSION = 0.12.0
YYJSON_SITE = $(call github,ibireme,yyjson,$(YYJSON_VERSION))
YYJSON_LICENSE = MIT
YYJSON_LICENSE_FILES = LICENSE
YYJSON_INSTALL_STAGING = YES

$(eval $(cmake-package))
