################################################################################
#
# ply
#
################################################################################

PLY_VERSION = 2.4.0
PLY_SITE = $(call github,wkz,ply,$(PLY_VERSION))
PLY_AUTORECONF = YES
PLY_LICENSE = GPL-2.0
PLY_LICENSE_FILES = COPYING
PLY_INSTALL_STAGING = YES
PLY_DEPENDENCIES = host-flex host-bison

define PLY_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_BPF_SYSCALL)
	$(call KCONFIG_ENABLE_OPT,CONFIG_KPROBES)
	$(call KCONFIG_ENABLE_OPT,CONFIG_UPROBES)
	$(call KCONFIG_ENABLE_OPT,CONFIG_TRACEPOINTS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_FTRACE)
	$(call KCONFIG_ENABLE_OPT,CONFIG_DYNAMIC_FTRACE)
	$(call KCONFIG_ENABLE_OPT,CONFIG_PERF_EVENTS)
endef

$(eval $(autotools-package))
