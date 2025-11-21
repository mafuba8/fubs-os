#!/bin/bash

set -ouex pipefail

# Load COPR helpers.
source /ctx/copr-helpers.sh


### Install packages from Fedora repos

# List taken from the DX setup, with some packages removed.
# https://github.com/ublue-os/aurora/blob/main/build_files/dx/00-dx.sh
FEDORA_PACKAGES=(
    bcc
    bpftop
    bpftrace
    cockpit-bridge
    cockpit-machines
    cockpit-networkmanager
    cockpit-ostree
    cockpit-podman
    cockpit-selinux
    cockpit-storaged
    cockpit-system
    dbus-x11
    edk2-ovmf
    flatpak-builder
    incus
    incus-agent
    iotop
    libvirt
    libvirt-nss
    nicstat
    numactl
    osbuild-selinux
    p7zip
    p7zip-plugins
    podman-compose
    podman-machine
    podman-tui
    qemu
    qemu-char-spice
    qemu-device-display-virtio-gpu
    qemu-device-display-virtio-vga
    qemu-device-usb-redirect
    qemu-img
    qemu-system-x86-core
    qemu-user-binfmt
    qemu-user-static
    rocm-hip
    rocm-opencl
    rocm-smi
    sysprof
    tmux
    trace-cmd
    udica
    virt-manager
    virt-v2v
    virt-viewer
    ydotool
)

echo "Installing ${#FEDORA_PACKAGES[@]} packages from Fedora repos..."
dnf5 -y install "${FEDORA_PACKAGES[@]}"


### Install packages from COPR.
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
echo "Installing COPR packages with isolated repo enablement..."

# Management tool for virtualization and kubernetes platforms
# https://github.com/karmab/kcli
copr_install_isolated "karmab/kcli" "kcli"

# Podman-bootc
# https://github.com/bootc-dev/podman-bootc
copr_install_isolated "gmaglione/podman-bootc" "podman-bootc"

# Ublue libvirt workarounds
# https://github.com/ublue-os/packages
copr_install_isolated "ublue-os/packages" "ublue-os-libvirt-workarounds"

# Openconnect in a pre-release version
copr_install_isolated "dwmw2/openconnect" "openconnect networkmanager-openconnect"


### Enable DX services.
systemctl enable podman.socket
systemctl enable swtpm-workaround.service
systemctl enable ublue-os-libvirt-workarounds.service
systemctl enable aurora-dx-groups.service

# NOTE: With isolated COPR installation, most repos are never enabled globally.
# We only need to clean up repos that were enabled during the build process.
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# NOTE: we won't use dnf5 copr plugin for ublue-os/akmods until our upstream provides the COPR standard naming
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

for i in /etc/yum.repos.d/rpmfusion-*; do
    sed -i 's@enabled=1@enabled=0@g' "$i"
done

