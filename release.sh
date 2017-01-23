#!/bin/bash
#
# Maintainer script for publishing releases.

set -e

source=$(dpkg-parsechangelog -S Source)
version=$(dpkg-parsechangelog -S Version)

OS=debian DIST=jessie ARCH=amd64 pbuilder-ev3dev build
debsign ~/pbuilder-ev3dev/debian/jessie-amd64/${source}_${version}_amd64.changes
dput ev3dev-debian ~/pbuilder-ev3dev/debian/jessie-amd64/${source}_${version}_amd64.changes

gbp buildpackage --git-tag-only

ssh ev3dev@reprepro.ev3dev.org "reprepro -b ~/reprepro/raspbian includedsc jessie \
    ~/reprepro/debian/pool/main/${source:0:1}/${source}/${source}_${version}.dsc"
ssh ev3dev@reprepro.ev3dev.org "reprepro -b ~/reprepro/raspbian includedeb jessie \
    ~/reprepro/debian/pool/main/${source:0:1}/${source}/ev3dev-tools_${version}_all.deb"
