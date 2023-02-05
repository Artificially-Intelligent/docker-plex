#!/usr/bin/with-contenv bash
. /usr/local/bin/variables

backup_files_to_keep=${backup_files_to_keep:-5}
# count files to keep only if file is greater than this threshold size
backup_size_threshold=${backup_size_threshold:-"10M"}

for  lib_file in "${library_files[@]}"
do
    # delete library db files older than ${library_db_backup_retention_days} days
    find "${library_db_backup_path_local}" -name ${lib_file}-docker-20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]*  -type f -mtime +${library_db_backup_retention_days} -exec rm -f {} \;
done


for  lib_file in "${library_files[@]}"; do
    sorted_files=$(find "${library_db_backup_path_local}" -name ${lib_file}-docker-20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]*  -type f -size +${backup_size_threshold} | sort)

    # Check how many files there are
    count=$(echo "$sorted_files" | wc -l)

    # Calculate the number of files to remove
    remove_count=$((count - ${backup_files_to_keep}))

    # If there are more than 5 files
    if [ $remove_count -gt 0 ]; then
        echo "found removing ${remove_count} old backup files"
        remove_files=$(echo "${sorted_files}" | head -n ${remove_count})

        # Loop over each line of the string
        while IFS='' read -r remove_file; do
            # Delete the file
            echo "removing old backup file: ${remove_file}"
            rm "${remove_file}"
        done <<< "$remove_files"
    fi
done