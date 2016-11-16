#!/bin/bash

set -xe

### not needed for finalduty/archlinux
# ### init
# sed -e "/^SigLevel/s/SigLevel.*/SigLevel = Never/" -i /etc/pacman.conf
# pacman -Sy --noconfirm pacman
# pacman-db-upgrade
# pacman -S --noconfirm pacman ca-certificates ca-certificates-mozilla archlinux-keyring

## install all packages
# libpipeline - binfmt-support
# yajl - package-query dependency
pacman -Suy --noconfirm --noprogressbar arch-install-scripts sudo base-devel wget curl openssh sshfs rsync xmlto kmod git bc lzop coreutils linux-firmware mkinitcpio libpipeline yajl

## enable sudo from nobody with nopasword, for 'sudo -u nobody makepkg -i' to work
echo "nobody ALL=(ALL:ALL) NOPASSWD: ALL" | (VISUAL="tee -a" EDITOR="tee -a" visudo)

## FIX stupid bug when sudo inside docker
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

## install yaourt
install_from_aur package-query
install_from_aur yaourt

## install binfmt and qemu-user-static
install_from_aur binfmt-support
install_from_aur qemu-user-static

## cleanup
yes Y | pacman -Scc


