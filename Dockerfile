# 
# RELEASE
# 

FROM lscr.io/linuxserver/plex:latest
LABEL maintainer="slink42"
LABEL org.opencontainers.image.source https://github.com/Artificially-Intelligent/docker-plex

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
        libxml2-utils \
        && \
#     echo "**** instaling plex-db-sync ****" && \
#     wget https://raw.githubusercontent.com/Fmstrat/plex-db-sync/master/plex-db-sync -O "/usr/local/bin/plex_db_sync.sh" && \
    echo "**** permissions ****" && \
    chmod a+x /usr/local/bin/* && \
    chmod a+x /etc/cont-init.d/* && \
    chmod a+x /etc/cont-finish.d/* && \
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
#     DATE_FORMAT="+%4Y/%m/%d %H:%M:%S"

HEALTHCHECK --interval=300s --timeout=60s --start-period=30s --retries=3 \
    CMD /usr/local/bin/healthcheck
    