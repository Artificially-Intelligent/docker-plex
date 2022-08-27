#!/usr/bin/with-contenv bash
    . /usr/local/bin/variables

temp_filename_start="library_images"

TAR_BACKUP_FOLDER="${library_images_backup_path_master}"
LOG_FILE="$TAR_BACKUP_FOLDER/.log"

LATEST_TAR_BACKUP_FOLDER_FILE=$(find "$TAR_BACKUP_FOLDER" -name ${temp_filename_start}_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9][0-9][0-9]_to_[0-9][0-9][0-9][0-9]-20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9][0-9][0-9].tar.gz | sort | tail -n 1)
LATEST_TAR_BACKUP_FOLDER_FILE=$(basename "$LATEST_TAR_BACKUP_FOLDER_FILE")
LATEST_TAR_BACKUP_DATE=$(echo $LATEST_TAR_BACKUP_FOLDER_FILE | cut -d "." -f1 | cut -d "_" -f5)

NEW_TAR_BACKUP_DATE=${LATEST_TAR_BACKUP_DATE:-"2021-01-01 0000"}
NEW_TAR_BACKUP_DATE=$(date --date="$NEW_TAR_BACKUP_DATE+1 month" +"${current_datetime_format}")

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
    
    TEMP_TAR_FILE="/tmp/${temp_filename_start}_${LATEST_TAR_BACKUP_DATE}_to_${NEW_TAR_BACKUP_DATE}.tar.gz"
    LOG_FILE="$TEMP_TAR_FILE.log"

    
    echo "$(date) ****** Starting image Libary tar file creation ******"
    echo "$(date) ****** Starting image Libary tar file creation ******" > "$LOG_FILE"

    echo "Temp Image Backup TAR: ${TEMP_TAR_FILE}"
    echo "Creating tar backup for file modified: ${min_file_mod_time} - ${max_file_mod_time}"
    echo "Creating tar backup for file modified: ${min_file_mod_time} - ${max_file_mod_time}" >> "$LOG_FILE"

    # find files last modified between dates and send to tar
    find "./Metadata" "./Media" -newermt "${min_file_mod_time}" ! -newermt "${max_file_mod_time}" -print0 | tar -cvzpf  "$TEMP_TAR_FILE" --null -T - >> "$LOG_FILE"

    if [ $(gzip -t "$TEMP_TAR_FILE") ]
    then
        echo "tar gzip compression tested ok, overwriting old version"
        mv "$TEMP_TAR_FILE" "$TAR_BACKUP_FOLDER/"
        mv "$LOG_FILE" "$TAR_BACKUP_FOLDER/"
    else
        echo "error tar gzip compression failed when tested, removing instead of overwriting old version"
        rm "$TEMP_TAR_FILE"
        break
    fi

    
    echo "$(date) ****** Finished image Libary tar file rebuild ******" >> "$LOG_FILE"
    echo "$(date) ****** Finished image Libary tar file rebuild ******"    
    
    # initalise next while loop
    LATEST_TAR_BACKUP_DATE="${NEW_TAR_BACKUP_DATE}"}
    NEW_TAR_BACKUP_DATE=$(date --date="$NEW_TAR_BACKUP_DATE+1 month" +"${current_datetime_format}")
done
