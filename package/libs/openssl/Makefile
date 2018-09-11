#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openssl
ifdef CONFIG_OPENSSL_USE_VERSION_1_0_2
PKG_BASE:=1.0.2
PKG_BUGFIX:=p
PKG_HASH:=50a98e07b1a89eb8f6a99477f262df71c6fa7bef77df4dc83025a2845c827d00
ENGINES_DIR=engines
endif

ifdef CONFIG_OPENSSL_USE_VERSION_1_1_0
PKG_BASE:=1.1.0
PKG_BUGFIX:=i
PKG_HASH:=ebbfc844a8c8cc0ea5dc10b86c9ce97f401837f3fa08c17b2cdadc118253cf99
ENGINES_DIR=engines-1.1
endif

ifdef CONFIG_OPENSSL_USE_VERSION_1_1_1
PKG_BASE:=1.1.1
PKG_BUGFIX:=
PKG_HASH:=2836875a0f89c03d0fdf483941512613a50cfb421d6fd94b9f41d7279d586a3d
ENGINES_DIR=engines-1.1
endif

PKG_VERSION:=$(PKG_BASE)$(PKG_BUGFIX)
PKG_RELEASE:=1
PKG_USE_MIPS16:=0
PATCH_DIR=./patches/$(PKG_BASE)

PKG_BUILD_PARALLEL:=0


PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
	http://ftp.fi.muni.cz/pub/openssl/source/ \
	http://ftp.linux.hr/pub/openssl/source/ \
	http://gd.tuwien.ac.at/infosys/security/openssl/source/ \
	http://www.openssl.org/source/ \
	http://www.openssl.org/source/old/$(PKG_BASE)/

PKG_LICENSE:=OpenSSL
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:openssl:openssl
PKG_CONFIG_DEPENDS:= \
	CONFIG_OPENSSL_ENGINE \
	CONFIG_OPENSSL_ENGINE_CRYPTO \
	CONFIG_OPENSSL_ENGINE_DIGEST \
	CONFIG_OPENSSL_ENGINE_PADLOCK \
	CONFIG_OPENSSL_OPTIMIZE_SPEED \
	CONFIG_OPENSSL_PREFER_CHACHA_OVER_GCM \
	CONFIG_OPENSSL_USE_VERSION_1_0_2 \
	CONFIG_OPENSSL_USE_VERSION_1_1_0 \
	CONFIG_OPENSSL_USE_VERSION_1_1_1 \
	CONFIG_OPENSSL_WITH_ARIA \
	CONFIG_OPENSSL_WITH_ASM \
	CONFIG_OPENSSL_WITH_ASYNC \
	CONFIG_OPENSSL_WITH_BLAKE2 \
	CONFIG_OPENSSL_WITH_CAMELLIA \
	CONFIG_OPENSSL_WITH_CHACHA_POLY1305 \
	CONFIG_OPENSSL_WITH_CMS \
	CONFIG_OPENSSL_WITH_COMPRESSION \
	CONFIG_OPENSSL_WITH_DEPRECATED \
	CONFIG_OPENSSL_WITH_DTLS \
	CONFIG_OPENSSL_WITH_EC \
	CONFIG_OPENSSL_WITH_EC2M \
	CONFIG_OPENSSL_WITH_GOST \
	CONFIG_OPENSSL_WITH_IDEA \
	CONFIG_OPENSSL_WITH_MDC2 \
	CONFIG_OPENSSL_WITH_NPN \
	CONFIG_OPENSSL_WITH_PSK \
	CONFIG_OPENSSL_WITH_RFC3779 \
	CONFIG_OPENSSL_WITH_SEED \
	CONFIG_OPENSSL_WITH_SM234 \
	CONFIG_OPENSSL_WITH_SRP \
	CONFIG_OPENSSL_WITH_SSE2 \
	CONFIG_OPENSSL_WITH_TLS13 \
	CONFIG_OPENSSL_WITH_WHIRLPOOL

include $(INCLUDE_DIR)/package.mk

ifneq ($(CONFIG_CCACHE),)
HOSTCC=$(HOSTCC_NOCACHE)
HOSTCXX=$(HOSTCXX_NOCACHE)
endif

define Package/openssl/Default
  TITLE:=Open source SSL toolkit
  URL:=http://www.openssl.org/
  SECTION:=libs
  CATEGORY:=Libraries
endef

define Package/libopenssl/config
source "$(SOURCE)/Config.in"
endef

define Package/openssl/Default/description
The OpenSSL Project is a collaborative effort to develop a robust,
commercial-grade, full-featured, and Open Source toolkit implementing the
Transport Layer Security (TLS) and Secure Sockets Layer (SSL) protocols as well
as a full-strength general-purpose cryptography library.
endef

define Package/libopenssl
$(call Package/openssl/Default)
  SUBMENU:=SSL
  DEPENDS:=+OPENSSL_WITH_COMPRESSION:zlib
  TITLE+= (libraries)
  ABI_VERSION:=$(PKG_VERSION)
  MENU:=1
endef

define Package/libopenssl/description
$(call Package/openssl/Default/description)
This package contains the OpenSSL shared libraries, needed by other programs.
endef

define Package/openssl-util
  $(call Package/openssl/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libopenssl
  TITLE+= (utility)
endef

define Package/openssl/conffiles
/etc/ssl/openssl.cnf
endef

define Package/openssl-util/description
$(call Package/openssl/Default/description)
This package contains the OpenSSL command-line utility.
endef

define Package/libopenssl-afalg
  $(call Package/openssl/Default)
  SUBMENU:=SSL
  TITLE:=AFALG hardware acceleration engine
  DEPENDS:=libopenssl @OPENSSL_ENGINE @!OPENSSL_USE_VERSION_1_0_2 +@KERNEL_AIO @!LINUX_3_18
endef

define Package/libopenssl-gost
  $(call Package/openssl/Default)
  SUBMENU:=SSL
  TITLE:=Russian GOST algorithms engine
  DEPENDS:=libopenssl @OPENSSL_ENGINE @OPENSSL_USE_VERSION_1_0_2 +@OPENSSL_WITH_GOST
endef

define Package/libopenssl-padlock
  $(call Package/openssl/Default)
  SUBMENU:=SSL
  TITLE:=VIA Padlock hardware acceleration engine
  DEPENDS:=libopenssl @OPENSSL_ENGINE @TARGET_x86
endef

OPENSSL_OPTIONS:= shared no-err

ifdef CONFIG_OPENSSL_USE_VERSION_1_0_2
  OPENSSL_OPTIONS += no-heartbeats no-sha0 no-ssl2-method no-ssl3-method
  # openssl 1.0.2 will not disable anything unless no-dtls1 is used.
  # Even with no-dtls and no-dtls1 options, the library keeps the DTLS code,
  # but openssl util gets built without it
  ifndef CONFIG_OPENSSL_WITH_DTLS
    OPENSSL_OPTIONS += no-dtls1
  endif
else
  ifndef CONFIG_OPENSSL_WITH_BLAKE2
    OPENSSL_OPTIONS += no-blake2
  endif
  ifndef CONFIG_OPENSSL_WITH_CHACHA_POLY1305
    OPENSSL_OPTIONS += no-chacha no-poly1305
  else
    ifdef CONFIG_OPENSSL_PREFER_CHACHA_OVER_GCM
      OPENSSL_OPTIONS += -DOPENSSL_PREFER_CHACHA_OVER_GCM
    endif
  endif
  ifndef CONFIG_OPENSSL_WITH_ASYNC
    OPENSSL_OPTIONS += no-async
  endif
endif

ifndef CONFIG_OPENSSL_WITH_EC
  OPENSSL_OPTIONS += no-ec
endif

ifndef CONFIG_OPENSSL_WITH_EC2M
  OPENSSL_OPTIONS += no-ec2m
endif

ifdef CONFIG_OPENSSL_USE_VERSION_1_1_1
# For reproducible builds, set a fixed date to show. It could be
# `date -r $(PKG_BUILD_DIR)/README %s`, but 1970-01-01 00:00:01 will get
# the message through. This may not be needed with the final release.
# Note that 0 won't work!
  OPENSSL_MAKEFLAGS += SOURCE_DATE_EPOCH=1

  ifndef CONFIG_OPENSSL_WITH_TLS13
    OPENSSL_OPTIONS += no-tls1_3
  endif
  ifndef CONFIG_OPENSSL_WITH_ARIA
    OPENSSL_OPTIONS += no-aria
  endif
  ifndef CONFIG_OPENSSL_WITH_SM234
    OPENSSL_OPTIONS += no-sm2 no-sm3 no-sm4
  endif
endif

ifndef CONFIG_OPENSSL_WITH_CAMELLIA
  OPENSSL_OPTIONS += no-camellia
endif

ifndef CONFIG_OPENSSL_WITH_IDEA
  OPENSSL_OPTIONS += no-idea
endif

ifndef CONFIG_OPENSSL_WITH_SEED
  OPENSSL_OPTIONS += no-seed
endif

ifndef CONFIG_OPENSSL_WITH_MDC2
  OPENSSL_OPTIONS += no-mdc2
endif

ifndef CONFIG_OPENSSL_WITH_WHIRLPOOL
  OPENSSL_OPTIONS += no-whirlpool
endif

ifndef CONFIG_OPENSSL_WITH_CMS
  OPENSSL_OPTIONS += no-cms
endif

# rfc3779 defaults as enabled in 1.1.0 and disabled in 1.0.2
ifndef CONFIG_OPENSSL_WITH_RFC3779
  OPENSSL_OPTIONS += no-rfc3779
else
  OPENSSL_OPTIONS += enable-rfc3779
endif

ifndef CONFIG_OPENSSL_WITH_DEPRECATED
  OPENSSL_OPTIONS += no-deprecated
endif

ifeq ($(CONFIG_OPENSSL_OPTIMIZE_SPEED),y)
  TARGET_CFLAGS := $(filter-out -O%,$(TARGET_CFLAGS)) -O3
else
  OPENSSL_OPTIONS += -DOPENSSL_SMALL_FOOTPRINT
endif

ifdef CONFIG_OPENSSL_ENGINE
  ifdef CONFIG_OPENSSL_ENGINE_CRYPTO
    OPENSSL_OPTIONS += -DHAVE_CRYPTODEV
    ifdef CONFIG_OPENSSL_ENGINE_DIGEST
      OPENSSL_OPTIONS += -DUSE_CRYPTODEV_DIGESTS
    endif
  endif
  ifndef CONFIG_PACKAGE_libopenssl-afalg
    ifndef CONFIG_OPENSSL_USE_VERSION_1_0_2
      OPENSSL_OPTIONS += no-afalgeng
    endif
  endif
  ifndef CONFIG_PACKAGE_libopenssl-padlock
    OPENSSL_OPTIONS += no-hw-padlock
  endif
else
  OPENSSL_OPTIONS += no-engine
endif

ifndef CONFIG_OPENSSL_WITH_GOST
  OPENSSL_OPTIONS += no-gost
endif

ifndef CONFIG_OPENSSL_WITH_DTLS
  OPENSSL_OPTIONS += no-dtls
endif

ifdef CONFIG_OPENSSL_WITH_COMPRESSION
  OPENSSL_OPTIONS += zlib-dynamic
else
  OPENSSL_OPTIONS += no-comp
endif

ifndef CONFIG_OPENSSL_WITH_NPN
  OPENSSL_OPTIONS += no-nextprotoneg
endif

ifndef CONFIG_OPENSSL_WITH_PSK
  OPENSSL_OPTIONS += no-psk
endif

ifndef CONFIG_OPENSSL_WITH_SRP
  OPENSSL_OPTIONS += no-srp
endif

ifndef CONFIG_OPENSSL_WITH_ASM
  OPENSSL_OPTIONS += no-asm
endif

ifdef CONFIG_i386
  ifndef CONFIG_OPENSSL_SSE2
    OPENSSL_OPTIONS += no-sse2
  endif
endif

OPENSSL_TARGET:=linux-$(CONFIG_ARCH)-openwrt

ifeq ($(CONFIG_x86_64)$(CONFIG_mips64)$(CONFIG_mips64el),y)
  OPENSSL_MAKEFLAGS += LIBDIR=lib
endif

STAMP_CONFIGURED := $(STAMP_CONFIGURED)_$(shell echo $(OPENSSL_OPTIONS) | mkhash md5)

define Build/Configure
	[ -f $(STAMP_CONFIGURED) ] || { \
		rm -f $(PKG_BUILD_DIR)/*.so.* $(PKG_BUILD_DIR)/*.a; \
		find $(PKG_BUILD_DIR) -name \*.o | xargs rm -f; \
	}
	(cd $(PKG_BUILD_DIR); \
		./Configure $(OPENSSL_TARGET) \
			--prefix=/usr \
			--openssldir=/etc/ssl \
			$(TARGET_CPPFLAGS) \
			$(TARGET_LDFLAGS) $(if $(CONFIG_OPENSSL_USE_VERSION_1_0_2),,-ldl) \
			$(OPENSSL_OPTIONS) \
	)
	$(if $(CONFIG_OPENSSL_USE_VERSION_1_0_2),
	  $(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		MAKEDEPPROG="$(TARGET_CROSS)gcc" \
		OPENWRT_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		$(OPENSSL_MAKEFLAGS) \
		depend,)

endef

TARGET_CFLAGS += $(FPIC) -I$(CURDIR)/include -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CC="$(TARGET_CC)" \
		ASFLAGS="$(TARGET_ASFLAGS) -I$(PKG_BUILD_DIR)/crypto -c" \
		AR="$(TARGET_CROSS)ar$(if $(CONFIG_OPENSSL_USE_VERSION_1_1_1),, r)" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		OPENWRT_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		$(OPENSSL_MAKEFLAGS) \
		all
	$(if $(CONFIG_OPENSSL_USE_VERSION_1_0_2),$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CC="$(TARGET_CC)" \
		ASFLAGS="$(TARGET_ASFLAGS) -I$(PKG_BUILD_DIR)/crypto -c" \
		AR="$(TARGET_CROSS)ar r" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		OPENWRT_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		$(OPENSSL_MAKEFLAGS) \
		build-shared
	  # Work around openssl build bug to link libssl.so with libcrypto.so.
	  -rm $(PKG_BUILD_DIR)/libssl.so.*.*.*
	  +$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CC="$(TARGET_CC)" \
		OPENWRT_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		$(OPENSSL_MAKEFLAGS) \
		do_linux-shared,)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CC="$(TARGET_CC)" \
		$(if $(CONFIG_OPENSSL_USE_VERSION_1_0_2),INSTALL_PREFIX,DESTDIR)="$(PKG_INSTALL_DIR)" \
		$(OPENSSL_MAKEFLAGS) \
		$(if $(CONFIG_OPENSSL_USE_VERSION_1_0_2),install,install_sw install_ssldirs)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/openssl $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{crypto,ssl}.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/{openssl,libcrypto,libssl}.pc $(1)/usr/lib/pkgconfig/
	[ -n "$(TARGET_LDFLAGS)" ] && $(SED) 's#$(TARGET_LDFLAGS)##g' $(1)/usr/lib/pkgconfig/{openssl,libcrypto,libssl}.pc || true
endef

define Package/libopenssl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libcrypto.so.* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libssl.so.* $(1)/usr/lib/
	$(if $(CONFIG_OPENSSL_ENGINE),$(INSTALL_DIR) $(1)/usr/lib/$(ENGINES_DIR))
endef

define Package/openssl-util/install
	$(INSTALL_DIR) $(1)/etc/ssl
	$(CP) $(PKG_INSTALL_DIR)/etc/ssl/openssl.cnf $(1)/etc/ssl/
	$(INSTALL_DIR) $(1)/etc/ssl/certs
	$(INSTALL_DIR) $(1)/etc/ssl/private
	chmod 0700 $(1)/etc/ssl/private
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/openssl $(1)/usr/bin/
endef

define Package/libopenssl-afalg/install
	$(INSTALL_DIR) $(1)/usr/lib/$(ENGINES_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/$(ENGINES_DIR)/afalg.so $(1)/usr/lib/$(ENGINES_DIR)
endef

define Package/libopenssl-padlock/install
	$(INSTALL_DIR) $(1)/usr/lib/$(ENGINES_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/$(ENGINES_DIR)/*padlock.so $(1)/usr/lib/$(ENGINES_DIR)
endef

define Package/libopenssl-gost/install
	$(INSTALL_DIR) $(1)/usr/lib/$(ENGINES_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/$(ENGINES_DIR)/libgost.so $(1)/usr/lib/$(ENGINES_DIR)
endef

$(eval $(call BuildPackage,libopenssl))
$(eval $(call BuildPackage,libopenssl-afalg))
$(eval $(call BuildPackage,libopenssl-gost))
$(eval $(call BuildPackage,libopenssl-padlock))
$(eval $(call BuildPackage,openssl-util))
