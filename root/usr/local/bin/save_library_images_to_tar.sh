#!/usr/bin/with-contenv bash
    . /usr/local/bin/variables

echo "$(date) ****** Starting save_library_images_to_tar.sh ******"

TAR_BACKUP_FOLDER="${library_images_backup_path_master}"

LATEST_TAR_BACKUP_FOLDER_FILE=$(find "$TAR_BACKUP_FOLDER" -name ${library_images_tar_filename_start}_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9][0-9][0-9]_to_[0-9][0-9][0-9][0-9]-20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9][0-9][0-9].tar.gz | sort | tail -n 1)
LATEST_TAR_BACKUP_FOLDER_FILE=$(basename "$LATEST_TAR_BACKUP_FOLDER_FILE")
LATEST_TAR_BACKUP_DATE=$(echo $LATEST_TAR_BACKUP_FOLDER_FILE | cut -d "." -f1 | cut -d "_" -f5)

NEW_TAR_BACKUP_DATE=${LATEST_TAR_BACKUP_DATE:-"2022-04-01 0000"}
NEW_TAR_BACKUP_DATE=$(date --date="$NEW_TAR_BACKUP_DATE+1 week" +"${current_datetime_format}")

LATEST_TAR_BACKUP_DATE=${LATEST_TAR_BACKUP_DATE:-"1970-01-01 0000"}

# change directory to root path for tar file
cd "$library_path_local"

while [ "$(date --date="${NEW_TAR_BACKUP_DATE}" +%s)" -lt "$(date +%s)" ]
do
    # set max_file_mod_time to now if in future    
    if [ $(date --date="${NEW_TAR_BACKUP_DATE}" +%s) -gt $(date +%s) ]; then
        NEW_TAR_BACKUP_DATE=$(date +"${current_datetime_format}")
    fi

    max_file_mod_time=$(date --date="${NEW_TAR_BACKUP_DATE}") 
    min_file_mod_time=$(date --date="${LATEST_TAR_BACKUP_DATE}")
    
    TEMP_TAR_FILE="/tmp/${library_images_tar_filename_start}_${LATEST_TAR_BACKUP_DATE}_to_${NEW_TAR_BACKUP_DATE}.tar.gz"
    LOG_FILE="$TEMP_TAR_FILE.log"
    LIST_FILE="${TEMP_TAR_FILE}_file_list.txt"

    
    echo "$(date) ****** Starting image Libary tar file creation ******"
    echo "$(date) ****** Starting image Libary tar file creation ******" > "$LOG_FILE"

    echo "Temp Image Backup TAR: ${TEMP_TAR_FILE}"

    # find files last modified between dates and send to tar
    echo "Finding files modified: ${min_file_mod_time} - ${max_file_mod_time}"
    echo "Finding files modified: ${min_file_mod_time} - ${max_file_mod_time}" >> "$LOG_FILE"
    find "./Metadata" "./Media" -newermt "${min_file_mod_time}" ! -newermt "${max_file_mod_time}" > "${LIST_FILE}"
    
    echo "$(date) Found $( cat "${LIST_FILE}" | wc -l) files. Adding to tar ${TEMP_TAR_FILE}" >> "$LOG_FILE"
    tar -czpf  "${TEMP_TAR_FILE}" -T  "${LIST_FILE}" >> "$LOG_FILE"

    if [ $(gzip -t "$TEMP_TAR_FILE") ]
    then
        ls -lah ${TEMP_TAR_FILE} >> "$LOG_FILE"
        echo "tar gzip compression tested ok, moving ${TEMP_TAR_FILE} to backup dir ${TAR_BACKUP_FOLDER}"
        mv "$TEMP_TAR_FILE" "$TAR_BACKUP_FOLDER/"
        echo "$(date) ****** Finished image Libary tar file load ******" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        echo "files added to tar:" >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        cat "$LIST_FILE" >> "$LOG_FILE"
        mv "$LOG_FILE" "$TAR_BACKUP_FOLDER/"
        rm "$LIST_FILE"
    else
        echo "error - tar gzip compression failed when tested, removing ${TEMP_TAR_FILE}" >> "$LOG_FILE"
        echo "error - tar gzip compression failed when tested, removing ${TEMP_TAR_FILE}"
        rm "$TEMP_TAR_FILE"
        #break
    fi
    
    
    echo "$(date) ****** Finished image Libary tar file rebuild ******"    
    
    # initalise next while loop
    LATEST_TAR_BACKUP_DATE="${NEW_TAR_BACKUP_DATE}"
    NEW_TAR_BACKUP_DATE=$(date --date="$NEW_TAR_BACKUP_DATE+1 month" +"${current_datetime_format}")
done


echo "$(date) ****** Finished save_library_images_to_tar.sh ******"