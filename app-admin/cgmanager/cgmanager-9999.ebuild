# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit autotools pam git-r3

DESCRIPTION="Control Group manager daemon"
HOMEPAGE="https://linuxcontainers.org/cgmanager/introduction/"
EGIT_REPO_URI="https://github.com/lxc/cgmanager.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ppc64 ~x86"
IUSE="selinux" # Note that PAM module is ALWAYS generated and installed!

RDEPEND="sys-libs/libnih[dbus]
	sys-apps/dbus
	selinux? ( sec-policy/selinux-cgmanager )"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch_user

	# systemd expects files in /sbin but we will have them in /usr/sbin
	pushd config/init/systemd > /dev/null || die
	sed -i -e "s@sbin@usr/&@" {${PN},cgproxy}.service || \
		die "Failed to fix paths in systemd service files"
	popd > /dev/null || die

	# there is an automagic dep on pam
	#epatch "${FILESDIR}/${PN}-0.39-make-pam-conditional.patch"
	eautoreconf
}

src_configure() {
	econf \
		--with-distro=gentoo \
		--with-pamdir="$(getpam_mod_dir)" \
		--with-init-script=systemd
}

src_install () {
	default

	# I see no reason to have the tests in the filesystem. Drop them
	rm -r "${D}"/usr/share/${PN}/tests || die "Failed to remove ${PN} tests"

	newinitd "${FILESDIR}"/${PN}.initd-r1 ${PN}
	newinitd "${FILESDIR}"/cgproxy.initd-r1 cgproxy
}
