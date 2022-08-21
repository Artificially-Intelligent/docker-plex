#!/usr/bin/with-contenv bash
. /usr/local/bin/variables

# fix database ownership
chown -R ${PLEX_UID}:${PLEX_GID} "${library_db_path_local}"
