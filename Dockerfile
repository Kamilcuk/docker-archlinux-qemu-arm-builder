FROM base/archlinux
MAINTAINER Kamil Cukrowski <kamilcukrowski@gmail.com>
COPY resources /
RUN  /docker-entrypoint.sh
