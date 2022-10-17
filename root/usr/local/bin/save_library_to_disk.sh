#!/usr/bin/with-contenv bash
. /usr/local/bin/variables

if  [ "${use_ramdisk}" = "YES" ]
then
    for library_db_file in $(ls "${ram_disk_db_path}")
    do
        ram_disk_db_file="${ram_disk_db_path}/${library_db_file}"
        backup_db_file=$(getNewBackupFilePath "${library_db_file}")

        echo "copying ram disk ${ram_disk_db_file} to backup path ${backup_db_file}"

        cp --remove-destination "${ram_disk_db_file}" "${backup_db_file}"
    done
    /usr/local/bin/remove_old_backups.sh
else
    echo "not using ramdisk, no need to save to disk"
fi