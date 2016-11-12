#!/bin/bash

set -xe

### init
sed -e "/^SigLevel/s/SigLevel.*/SigLevel = TrustAll/" -i /etc/pacman.conf
pacman -Sy --noconfirm pacman
pacman-db-upgrade
pacman -S --noconfirm pacman ca-certificates ca-certificates-mozilla archlinux-keyring

## install packages
pacman -Suy --noconfirm pacman arch-install-scripts sudo base-devel wget curl

## enable sudo from nobody
echo "nobody ALL=(ALL:ALL) NOPASSWD: ALL" | (VISUAL="tee -a" EDITOR="tee -a" visudo)
sed -e "/nice/s/\*/#*/" -i /etc/security/limits.conf

## install packages from aur
echo -ne "[archlinuxfr]\nServer = http://repo.archlinux.fr/\$arch\n" >> /etc/pacman.conf
pacman -Sy --noconfirm yaourt
sudo -u nobody yaourt -S --noconfirm binfmt-support #qemu-user-static

# qemu-user-static byl updatowany 8 listopada i jeszcze nie działa :( :( :(
pacman -S --noconfirm git
git clone https://aur.archlinux.org/qemu-user-static.git /qemu-user-static
chown "nobody:nobody" -R /qemu-user-static
cd /qemu-user-static && sed -i PKGBUILD -e "s/^_debsrc=.*/_debsrc=\${pkgname}_\${pkgver}+dfsg-3+b1_\${_arch}.deb/" -e "s/^sha1sums=.*/sha1sums=('f557e92dddb0b0a81a80ba69474295073b364574')/"
cd /qemu-user-static && yes Y | sudo -u nobody makepkg -i

### not needed for build
# error - błąd! niestety, z powodu tego że jesteśmy w dockerze
# filesystem binfmt_misc jest nie podmontowany
# potrzebujemy uruchomić się z --privileged / lub cap_add SYS_ADMIN 
#, i zrobić: mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
#mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
#update-binfmts --enable qemu-arm

rootfsarchive=ArchLinuxARM-rpi-2-latest.tar.gz
wget -c -O ~/$rootfsarchive http://os.archlinuxarm.org/os/$rootfsarchive
rootfsarchive=ArchLinuxARM-armv7-latest.tar.gz
wget -c -O ~/$rootfsarchive http://os.archlinuxarm.org/os/$rootfsarchive


