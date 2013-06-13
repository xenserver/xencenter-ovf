#!/bin/sh

# Copyright (c) Citrix Systems Inc. 
# All rights reserved.
# 
# Redistribution and use in source and binary forms, 
# with or without modification, are permitted provided 
# that the following conditions are met: 
# 
# *   Redistributions of source code must retain the above 
#     copyright notice, this list of conditions and the 
#     following disclaimer. 
# *   Redistributions in binary form must reproduce the above 
#     copyright notice, this list of conditions and the 
#     following disclaimer in the documentation and/or other 
#     materials provided with the distribution. 
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
# SUCH DAMAGE.

#
# The automated XenServer build requires that builds run without access to the
# internet.  This requires a patch to lh_chroot_sources, lh_binary, and
# lh_source to bind-mount the mirror into the chroot.  Also, we have to patch
# packages.sh to add --force-yes to apt-get command line, since we don't have
# the Release.gpg files.  We also patch lh_config and lh_chroot to add the
# capability to have separate binary and source URLs inside the chroot.
# Finally, we patch function.sh for extra verbosity in the build.
#
# We only have Lenny DVD 1 in our mirror, and other packages are
# brought in separately, as specified with the fourth command line argument.
# Sources are stored separately, as specified by the fifth and sixth
# arguments.
#
# If building outside of the automated XenServer build, you don't need to
# supply the other packages separately, and don't need to patch live-helper,
# so supply an HTTP mirror for the third argument, and empty strings for the
# fourth, fifth, and sixth.
#

set -eux

outdir="$1"
regmod="$2"
mirror="$3"
extrapacks="$4"
source_mirror="$5"
sources="$6"

extrapackages="aufs-modules-2.6-686_2.6.26-6+lenny1_i386.deb aufs-modules-2.6.26-2-686_2.6.26+0+20080719-6+lenny1_i386.deb linux-image-2.6-686_2.6.26+17+lenny1_i386.deb linux-image-2.6.26-2-686_2.6.26-19lenny2_i386.deb live-initramfs_1.156.1+1.157.2-1_all.deb squashfs-modules-2.6-686_2.6.26-6+lenny1_i386.deb squashfs-modules-2.6.26-2-686_2.6.26+3.3-6+lenny1_i386.deb squashfs-tools_3.3-7_i386.deb user-setup_1.23_all.deb"

destbin="$outdir/xenserver-linuxfixup-disk.iso"
destsrc="$outdir/xenserver-linuxfixup-disk-sources.tar.gz"

thisdir=$(dirname "$0")

tempdir=$(mktemp -d -p "$outdir")
incdir="$tempdir/config/chroot_local-includes"
hooksdir="$tempdir/config/chroot_local-hooks"
packagesdir="$tempdir/config/chroot_local-packages"
chrootdir="$tempdir/chroot"

is_file_mirror=$(expr match "$mirror" "file:" || true)

if [ "$is_file_mirror" != "0" ]
then
  patch -d / -p0 <"$thisdir/live-helper.patch"
fi

function cleanup()
{
  umount "$chrootdir/distros" || true
  umount "$chrootdir/distfiles" || true
  rm -rf --one-file-system "$tempdir"
  if [ "$is_file_mirror" != "0" ]
  then
    patch -R -d / -p0 <"$thisdir/live-helper.patch"
  fi
}

trap cleanup ERR

cd "$tempdir"
lh_config
mkdir -p "$incdir/etc"
mkdir -p "$incdir/root"
mkdir -p "$incdir/usr/bin"
cp "$thisdir/rc.local" "$incdir/etc"
cp "$thisdir/kensho.script" "$incdir/root"
cp "$thisdir/vmware.script" "$incdir/root"
cp "$regmod" "$incdir/usr/bin"
chmod u=rx "$incdir"/etc/*
chmod u=rx "$incdir"/root/*
chmod u=rx "$incdir"/usr/bin/*
cp "$thisdir"/hooks/* "$hooksdir"
chmod u=rx "$hooksdir"/*
if [ "$extrapacks" ]
then
  (cd "$extrapacks"
   cp $extrapackages "$packagesdir")
fi
if [ "$is_file_mirror" != "0" ]
then
  source_mirror_arg="--mirror-chroot-source $source_mirror"
else
  source_mirror_arg=""
fi
lh_config --binary-images iso --bootstrap-flavour minimal \
          --security disabled \
          --source enabled --source-images tar \
          --mirror-bootstrap "$mirror" \
          --mirror-chroot "$mirror" \
          --mirror-binary "$mirror" \
          $source_mirror_arg \
          --packages-lists stripped --apt apt \
          --apt-options "--yes --force-yes" \
          --apt-recommends disabled --tasksel none \
          --binary-indices disabled --distribution lenny \
          --linux-flavours 686 --memtest none \
          --bootappend-live "nolocales noautologin noprompt" \
          --packages "lvm2 reiserfsprogs ntfs-3g ntfsprogs cabextract openssl" \
          --syslinux-timeout 3 && \
if [ "$sources" ]
then
  mkdir -p "$chrootdir"
  cp "$sources" "$chrootdir/Sources"
fi
lh_build
cp "$tempdir/binary.iso" "$destbin"
cp "$tempdir/source.tar.gz" "$destsrc"
cleanup
