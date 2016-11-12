FROM base/archlinux
MAINTAINER Kamil Cukrowski <kamilcukrowski@gmail.com>
COPY docker-entrypoint.sh /
RUN  /docker-entrypoint.sh
