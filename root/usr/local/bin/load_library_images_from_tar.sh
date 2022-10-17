#!/usr/bin/with-contenv bash
. /usr/local/bin/variables

temp_filename_start="library_images"

TAR_BACKUP_FOLDER="${library_images_backup_path_master}"
LOG_FILE="${library_path_local}/library_images.log"
DONE_FILE="${library_path_local}/library_images_loaded.dat"
FOUND_FILE="${library_path_local}/library_images_found.dat"

[ -f "${DONE_FILE}" ] && loaded_tar_backup_files=$(cat ${DONE_FILE}) || 

find "$TAR_BACKUP_FOLDER" -name "${library_images_tar_filename_start}_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9][0-9][0-9]_to_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9][0-9][0-9]_[0-9][0-9][0-9].tar.gz" | sort > "${FOUND_FILE}"

echo "$(date) ****** Starting image Libary load from tar $(cat "${FOUND_FILE}" | wc -l) file(s) ******"

cd "${library_path_local}"
while read tar_backup_file;
do 
    tar_backup_filename=$(basename "${tar_backup_file}")
    if [[ $(cat "${DONE_FILE}" | grep "${tar_backup_filename}") ]]
    then
        echo "skipping and deleted tar found in done file ($DONE_FILE): \"${tar_backup_file}\""
        rm "${tar_backup_file}"
    else
        if [ $(gzip -t "${tar_backup_file}") ]
        then
            echo "Loading images from Image Backup TAR: $tar_backup_file"
            #tar -xzf "$tar_backup_file" -C "$library_path_local" --checkpoint=.5000
            # formatted to match rclone --filter-from requirements
            echo "- ${tar_backup_filename}" >>  "${DONE_FILE}"
        else
            echo "error tar gzip compression failed when tested, removing file from disk ahead of fresh download from cloud storage: ${tar_backup_file}"
            rm "${tar_backup_file}"
        fi
    fi
done < "${FOUND_FILE}"

echo "$(date) ****** Finished image Libary load from tar file ******"
echo "$(date) ****** Starting image Libary load from tar file ******" > "$LOG_FILE"