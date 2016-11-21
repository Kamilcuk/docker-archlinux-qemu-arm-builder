#!/bin/bash

set -xe
echo "===> START $0 $*"

linaro=gcc-linaro-6.1.1-2016.08-x86_64_arm-linux-gnueabihf

### not needed for finalduty/archlinux
# ### init
# echo "===> Make pacman work"
# sed -e "/^SigLevel/s/SigLevel.*/SigLevel = Never/" -i /etc/pacman.conf
# pacman -Sy --noconfirm pacman
# pacman-db-upgrade
# pacman -S --noconfirm pacman ca-certificates ca-certificates-mozilla archlinux-keyring

echo "===> Update&install all needed packages"
# libpipeline - binfmt-support dependency
# yajl - package-query dependency
pacman -Suy --noconfirm --noprogressbar arch-install-scripts sudo base-devel wget curl openssh sshfs rsync xmlto kmod git bc lzop coreutils linux-firmware mkinitcpio libpipeline yajl

echo "===> enable sudo from nobody with nopasword, for 'sudo -u nobody makepkg -i' to work"
echo "nobody ALL=(ALL:ALL) NOPASSWD: ALL" | (VISUAL="tee -a" EDITOR="tee -a" visudo)

echo "===> FIX stupid bug when sudo inside docker"
#http://bit-traveler.blogspot.com/2015/11/sudo-error-within-docker-container-arch.html
sed -e "/nice/s/\*/#*/" -i /etc/security/limits.conf

## install_from_aur
install_from_aur() {
	local name=$1
	local tmpdir=/home/$name
	git clone https://aur.archlinux.org/$name.git $tmpdir
	chown nobody:nobody -R $tmpdir
	pushd $tmpdir
	sudo -Eu nobody makepkg --noconfirm --nosign -si
	popd
	rm -rf $tmpdir
}

echo "===> install yaourt"
install_from_aur package-query
install_from_aur yaourt

echo "===> install binfmt and qemu-user-static"
install_from_aur binfmt-support
install_from_aur qemu-user-static


echo "==> Download $linaro to /opt"
curl -L -o /opt/$linaro.tar.xz https://releases.linaro.org/components/toolchain/binaries/6.1-2016.08/arm-linux-gnueabihf/$linaro.tar.xz

echo "==> Upacking linaro"
tar xfp /opt/$linaro.tar.xz -C /opt
rm -f /opt/$linaro.tar.xz
ln -s /opt/$linaro /opt/gcc-linaro


echo "===> cleanup"
yes Y | pacman -Scc

echo "===> DONE $0 $*"

