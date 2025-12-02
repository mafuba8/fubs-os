#!/bin/bash

set -ouex pipefail

# Install kvmkr (experimental).
# /ctx/build_files/vfio.sh

### Copy system files (like systemd-services)
rsync -rvK /ctx/system_files/ /


### Install packages from Fedora repos
/ctx/build_files/packages.sh


### Install Canon printer drivers.
#/ctx/build_files/printer-driver.sh


### Enable DX services.
systemctl enable podman.socket
systemctl enable swtpm-workaround.service
systemctl enable ublue-os-libvirt-workarounds.service
systemctl enable fubs-os-groups

# NOTE: With isolated COPR installation, most repos are never enabled globally.
# We only need to clean up repos that were enabled during the build process.
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# NOTE: we won't use dnf5 copr plugin for ublue-os/akmods until our upstream provides the COPR standard naming
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

for i in /etc/yum.repos.d/rpmfusion-*; do
    sed -i 's@enabled=1@enabled=0@g' "$i"
done


### Cleanup
dnf5 clean all
