ARG UBUNTU_VER=20.04

ARG UBUNTU_VER_SHA=@sha256:6cad3b09aa963b47380bbf0053980f22d27bb4b575ff5b171bb9c00a239ad018
#FROM ubuntu:${UBUNTU_VER} AS ubuntu
FROM ghcr.io/by275/base:ubuntu${UBUNTU_VER}${UBUNTU_VER_SHA} AS prebuilt

# 
# RELEASE
# 

FROM lscr.io/linuxserver/plex:latest
LABEL maintainer="slink42"
LABEL org.opencontainers.image.source https://github.com/Artificially-Intelligent/docker-plex


# add go-cron
COPY --from=prebuilt /go/bin/go-cron /bar/usr/local/bin/

# add local files
COPY root/ /

# # install packages
RUN \
    echo "**** apt source change for local build ****" && \
    # sed -i "s/archive.ubuntu.com/$APT_MIRROR/g" /etc/apt/sources.list && \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
        cron \
        sqlite3 \
        sshfs \
        && \
#     echo "**** instaling plex-db-sync ****" && \
#     wget https://raw.githubusercontent.com/Fmstrat/plex-db-sync/master/plex-db-sync -O "/usr/local/bin/plex_db_sync.sh" && \
# #     update-ca-certificates && \
# #     sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf && \
    echo "**** permissions ****" && \
    chmod a+x /usr/local/bin/* && \
    echo "**** cleanup ****" && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /tmp/* /var/lib/{apt,dpkg,cache,log}/ && \
    echo "**** install complete ****" 

# # environment settings
# ENV \
#     S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
#     S6_KILL_FINISH_MAXTIME=7000 \
#     S6_SERVICES_GRACETIM=5000 \
#     S6_KILL_GRACETIME=5000 \
#     LANG=C.UTF-8 \
#     PS1="\u@\h:\w\\$ " \
#     RCLONE_CONFIG=/config/rclone.conf \
#     RCLONE_REFRESH_METHOD=default \
#     UFS_USER_OPTS="cow,direct_io,nonempty,auto_cache,sync_read" \
#     MFS_USER_OPTS="rw,use_ino,func.getattr=newest,category.action=all,category.create=ff,cache.files=auto-full,dropcacheonclose=true" \
#     DATE_FORMAT="+%4Y/%m/%d %H:%M:%S"

HEALTHCHECK --interval=300s --timeout=60s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck
    