FROM linuxserver/plex

# add local files overwriting prior additions
COPY root/etc/cont-init.d/46-plex-server-settings /etc/cont-init.d/46-plex-server-settings
