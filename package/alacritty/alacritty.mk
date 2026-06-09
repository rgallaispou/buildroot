################################################################################
#
# alacritty
#
################################################################################

ALACRITTY_VERSION = 0.17
ALACRITTY_SITE = $(call github,alacritty,alacritty,v$(ALACRITTY_VERSION))
ALACRITTY_LICENSE = Apache-2.0, MIT
ALACRITTY_LICENSE_FILES = LICENSE-APACHE LICENSE-MIT
ALACRITTY_DEPENDENCIES = wayland wayland-protocols libxkbcommon freetype fontconfig

ALACRITTY_SUBDIR = alacritty
ALACRITTY_CARGO_BUILD_OPTS = --no-default-features --features=wayland
ALACRITTY_CARGO_INSTALL_OPTS = --no-default-features --features=wayland

define ALACRITTY_INSTALL_ADDITIONAL_FILES
	# Create destination folders if the do not exist
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/applications
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/pixmaps

	# Install .desktop file
	$(INSTALL) -D -m 0644 $(@D)/extra/linux/Alacritty.desktop \
		$(TARGET_DIR)/usr/share/applications/Alacritty.desktop

	# Install SVG icon
	$(INSTALL) -D -m 0644 $(@D)/extra/logo/alacritty-term.svg \
		$(TARGET_DIR)/usr/share/pixmaps/Alacritty.svg
endef

ALACRITTY_POST_INSTALL_TARGET_HOOKS += ALACRITTY_INSTALL_ADDITIONAL_FILES

$(eval $(cargo-package))
