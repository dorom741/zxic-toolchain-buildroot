################################################################################
#
# fakeroot
#
################################################################################

FAKEROOT_VERSION = 1.32.1
FAKEROOT_SOURCE = fakeroot_$(FAKEROOT_VERSION).orig.tar.gz
FAKEROOT_SITE = https://snapshot.debian.org/archive/debian/20230724T160429Z/pool/main/f/fakeroot
FAKEROOT_LICENSE = GPL-3.0+
FAKEROOT_LICENSE_FILES = COPYING

# Force capabilities detection off: process capabilities in faked are of
# no real use, and this avoids depending on a host libcap.
HOST_FAKEROOT_CONF_ENV = \
	ac_cv_header_sys_capability_h=no \
	ac_cv_func_capset=no

$(eval $(host-autotools-package))
