#!/bin/bash
#
# Maintainer script for publishing releases.

set -e

export SKIP_CYTHON_BUILD=1

source=$(dpkg-parsechangelog -S Source)
version=$(dpkg-parsechangelog -S Version)
distribution=$(dpkg-parsechangelog -S Distribution)

OS=debian DIST=${distribution} ARCH=amd64 pbuilder-ev3dev build
debsign ~/pbuilder-ev3dev/debian/${distribution}-amd64/${source}_${version}_amd64.changes
dput ev3dev-debian ~/pbuilder-ev3dev/debian/${distribution}-amd64/${source}_${version}_amd64.changes

gbp buildpackage --git-tag-only

ssh ev3dev@reprepro.ev3dev.org "reprepro -b ~/reprepro/raspbian includedsc ${distribution} \
    ~/reprepro/debian/pool/main/${source:0:1}/${source}/${source}_${version}.dsc"
ssh ev3dev@reprepro.ev3dev.org "reprepro -b ~/reprepro/raspbian includedeb ${distribution} \
    ~/reprepro/debian/pool/main/${source:0:1}/${source}/python-ptvsd_${version}_all.deb"
ssh ev3dev@reprepro.ev3dev.org "reprepro -b ~/reprepro/raspbian includedeb ${distribution} \
    ~/reprepro/debian/pool/main/${source:0:1}/${source}/python3-ptvsd_${version}_all.deb"
