# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

PLOCALES="de fr ja"
IUSE="+criu +daemon +image +lvm nls test"

# IUSE and PLOCALES must be defined before l10n inherited
inherit bash-completion-r1 eutils l10n systemd user

DEPEND="
	dev-go/go-crypto
	>=dev-lang/go-1.4.2:=
	dev-libs/protobuf
	dev-vcs/git
	nls? ( sys-devel/gettext )
	test? (
		app-misc/jq
		dev-db/sqlite
		net-misc/curl
		sys-devel/gettext
	)
"

RDEPEND="
	daemon? (
		app-admin/cgmanager
		app-arch/xz-utils
		app-emulation/lxc[cgmanager]
		net-analyzer/openbsd-netcat
		net-misc/bridge-utils
		virtual/acl
		criu? (
			sys-process/criu
		)
		image? (
			app-crypt/gnupg
			>=dev-lang/python-3.2
		)
		lvm? (
			sys-fs/lvm2
		)
	)
"

pkg_setup() {
	export GOPATH=${WORKDIR}/${P}
}
src_unpack() {
	go get github.com/lxc/lxd
}
src_prepare() {
	cd "${WORKDIR}/${P}/src/github.com/lxc/lxd"
}
src_compile() {
	cd "${WORKDIR}/${P}/src/github.com/lxc/lxd"
	emake
}
src_install() {
	cd "${WORKDIR}/${P}"
	
	dobin bin/lxc
	if use daemon; then
		dobin bin/fuidshift
		dobin bin/lxd
	fi
	
	dobin bin/fuidshift
	dobin bin/lxd-bridge-proxy
	
	if use image; then
		dobin src/github.com/lxc/lxd/scripts/lxd-images
	fi
	
	if use lvm; then
		dobin src/github.com/lxc/lxd/scripts/lxd-setup-lvm-storage
	fi
	
	if use nls; then
		for lingua in ${PLOCALES}; do
			if use linguas_${lingua}; then
				domo src/github.com/lxc/lxd/po/${lingua}.mo
			fi
		done
	fi
	
	if use daemon; then
		newinitd "${FILESDIR}"/${P}.initd lxd
		newconfd "${FILESDIR}"/${P}.confd lxd

		systemd_dounit "${FILESDIR}"/lxd.service
	fi
	
	newbashcomp src/github.com/lxc/lxd/config/bash/lxc.in lxc
	
	docinto src/github.com/lxc/lxd/specs
	dodoc src/github.com/lxc/lxd/specs/*
}
pkg_postinst() {
	einfo
	einfo "Consult https://wiki.gentoo.org/wiki/LXD for more information,"
	einfo "including a Quick Start."

	# The messaging below only applies to daemon installs
	use daemon || return 0

	# The control socket will be owned by (and writeable by) this group.
	enewgroup lxd

	# Ubuntu also defines an lxd user but it appears unused (the daemon
	# must run as root)

	if test -n "${REPLACING_VERSIONS}"; then
		einfo
		einfo "If you are upgrading from version 0.14 or older, note that the --tcp"
		einfo "is no longer available in /etc/conf.d/lxd.  Instead, configure the"
		einfo "listen address/port by setting the core.https_address profile option."
	fi
}
