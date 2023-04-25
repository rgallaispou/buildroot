#!/bin/sh

set -eux

# Mount /boot
if [ -e "${TARGET_DIR}/etc/fstab" ]; then
	mkdir -p "${TARGET_DIR}/boot" && touch "${TARGET_DIR}/boot/.keep"
	FSTAB="${TARGET_DIR}/etc/fstab"
	APPEND='/dev/mmcblk0p1 /boot vfat rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro 0 0'
	grep -qxF "$APPEND" "$FSTAB" || echo "$APPEND" >> "$FSTAB"
fi
