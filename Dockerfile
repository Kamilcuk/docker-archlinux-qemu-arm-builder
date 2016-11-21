FROM finalduty/archlinux:latest
MAINTAINER Kamil Cukrowski <kamilcukrowski@gmail.com>
COPY resources /
RUN  /docker-entrypoint.sh


