# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils git-r3 linux-info autotools autotools-utils systemd

DESCRIPTION="FUSE filesystem for LXC"
HOMEPAGE="https://linuxcontainers.org/lxcfs/"
EGIT_REPO_URI="https://github.com/lxc/lxcfs.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND=">=sys-apps/dbus-1.0.0
		>=sys-libs/libnih-1.0.2[dbus]
		app-admin/cgmanager
		sys-fs/fuse"
RDEPEND="${DEPEND}"


CONFIG_CHECK="FUSE_FS"

AUTOTOOLS_AUTORECONF=1

src_install() {
	autotools-utils_src_install
	dodir "/var/lib/${PN}"
	newinitd "${FILESDIR}/${PN}.init" lxcfs
	systemd_dounit "${FILESDIR}/${PN}.service"
}
