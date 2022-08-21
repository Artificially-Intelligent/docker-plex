#!/usr/bin/with-contenv bash
. /usr/local/bin/variables

if  [ "${use_ramdisk}" = "YES" ]
then
    # Keep in sync with paths used in load_master_library_db.sh
    ram_disk_db_path="${ram_disk_path}/Plug-in Support/Databases"

    for library_db_file in $(ls "${ram_disk_db_path}")
    do
        ram_disk_db_file="${ram_disk_db_path}/${library_db_file}"
        backup_db_file=$(getNewBackupFilePath)

        echo "copying ram disk ${ram_disk_db_file} to backup path ${backup_db_file}"

        cp --remove-destination "${ram_disk_db_file}"  "${backup_db_file}"
    done 
else
    echo "not using ramdisk, no need to save to disk"
fi