#!/usr/bin/with-contenv bash
    . /usr/local/bin/variables

temp_filename_start="library_images"

TAR_BACKUP_FOLDER="${library_images_backup_path_master}"
LOG_FILE="$TEMP_TAR_FILE.log"

LATEST_TAR_BACKUP_FOLDER_FILE=$(find "$TAR_BACKUP_FOLDER" -name ${temp_filename_start}_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]_to_[0-9][0-9][0-9][0-9]-20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9].tar.gz | sort | tail -n 1)
LATEST_TAR_BACKUP_FOLDER_FILE=$(basename "$LATEST_TAR_BACKUP_FOLDER_FILE")
LATEST_TAR_BACKUP_DATE=$(echo $LATEST_TAR_BACKUP_FOLDER_FILE | cut -d "." -f1 | cut -d "_" -f5)
LATEST_TAR_BACKUP_DATE=${LATEST_TAR_BACKUP_DATE:-"0000-00-00-0000"}
echo "Latest Image Backup TAR: ${LATEST_TAR_BACKUP_FOLDER_FILE}"

TEMP_TAR_FILE="/tmp/${temp_filename_start}_${LATEST_TAR_BACKUP_DATE}_to_${current_datetime}.tar.gz"
echo "Temp Image Backup TAR: ${TEMP_TAR_FILE}"

echo "$(date) ****** Starting image Libary tar file rebuild ******"
echo "$(date) ****** Starting image Libary tar file rebuild ******" > "$LOG_FILE"
cd "$library_root_path_local"
tar -cvpzf "$TEMP_TAR_FILE" "./Application Support/Plex Media Server/Metadata" "./Application Support/Plex Media Server/Media" >> "$LOG_FILE"

if [ $(gzip -t "$TEMP_TAR_FILE") ]
then
    echo "tar gzip compression tested ok, overwriting old version"
    mv "$TEMP_TAR_FILE" "$TAR_BACKUP_FOLDER/"
    mv "$LOG_FILE" "$TAR_BACKUP_FOLDER/"
else
    echo "error tar gzip compression failed when tested, removing instead of overwriting old version"
    rm "$TEMP_TAR_FILE"
fi

echo "$(date) ****** Finished image Libary tar file rebuild ******" >> "$LOG_FILE"
echo "$(date) ****** Finished image Libary tar file rebuild ******"