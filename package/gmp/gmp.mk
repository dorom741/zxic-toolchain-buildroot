################################################################################
#
# gmp
#
################################################################################

GMP_VERSION = 6.0.0a
GMP_SITE = $(BR2_GNU_MIRROR)/gmp
GMP_SOURCE = gmp-$(GMP_VERSION).tar.xz
GMP_INSTALL_STAGING = YES
GMP_LICENSE = LGPLv3+
GMP_LICENSE_FILES = COPYING.LESSERv3
GMP_DEPENDENCIES = host-m4

# GMP 6.0.0a's configure tests use K&R-style declarations. GCC 14
# diagnoses those declarations as errors under its default gnu17 mode.
GMP_CONF_ENV += CC_FOR_BUILD="$(HOSTCC) -std=gnu89"

# GMP 6.0.0a's configure tests use K&R-style declarations. GCC 14
# diagnoses those declarations as errors under its default gnu17 mode.
HOST_GMP_CONF_ENV += CFLAGS="$(HOST_CFLAGS) -std=gnu89"

$(eval $(autotools-package))
$(eval $(host-autotools-package))
