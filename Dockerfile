FROM finalduty/archlinux:latest
MAINTAINER Kamil Cukrowski <kamilcukrowski@gmail.com>
RUN pacman -Suy --downloadonly --noconfirm --noprogressbar arch-install-scripts sudo base-devel wget curl openssh sshfs rsync xmlto kmod git bc lzop coreutils linux-firmware mkinitcpio libpipeline yajl
RUN echo "==> Download gcc-linaro to /opt" && \
    dir=gcc-linaro-6.1.1-2016.08-x86_64_arm-linux-gnueabihf && \
    curl -L -o /opt/$dir.tar.xz https://releases.linaro.org/components/toolchain/binaries/6.1-2016.08/arm-linux-gnueabihf/$dir.tar.xz
COPY resources /
RUN  /docker-entrypoint.sh
RUN echo "==> Untar gcc-linaro (docker will tar it again)" && \
    dir=gcc-linaro-6.1.1-2016.08-x86_64_arm-linux-gnueabihf && \
    tar xfp /opt/$dir.tar.xz -C /opt && \
    rm -f /opt/$dir.tar.xz && \
    ln -s /opt/$dir /opt/gcc-linaro && \
    echo "==> DONE!"


