#!/usr/bin/bash

# Rename files in pictures directory by their MD5 hash

FORMAT_RED="\033[0;1;31m"
FORMAT_GREEN="\033[0;1;32m"
FORMAT_YELLOW="\033[0;1;33m"
FORMAT_BLUE="\033[0;1;34m"
FORMAT_RESET="\033[0m"

__dirname="$(dirname $0)"
cd $__dirname

MODE=rename
OVERWRITE=
EXIT_CODE=0

if [[ $* == *--check* ]]; then
    MODE=check
fi
if [[ $* == *--help* ]];then
    MODE=help
fi
if [[ $* == *--overwrite* ]]; then
    OVERWRITE=1
fi

if [[ "$MODE" == "help" ]];then
    echo "Usage: $0 [options]"
    echo "Rename or check files in the pictures directory by their MD5 hash"
    echo "If no options are given, rename files by their MD5 hash"
    echo "Options:"
    echo "  --help                 Show this help message and exit"
    echo "  --check                Check if file names are correct"
    echo "  --overwrite            Overwrite files with the same name"
    echo "                         (instead of showing a warning and skip)"
    exit 0
fi

# Check if md5sum is installed
if ! command -v md5sum &> /dev/null; then
    echo "${FORMAT_RED}Error: md5sum is not installed${FORMAT_RESET}"
    exit 2
fi

# Check if the directory exists
if [ ! -d "../pictures" ]; then
    echo -e "${FORMAT_RED}Error: Directory pictures does not exist${FORMAT_RESET}"
    exit 1
fi
# Change to the pictures directory
cd ../pictures

# Get the list of files in the directory
files=(**/*)
echo -e "${FORMAT_BLUE}Info: Found ${#files[@]} files in the directory${FORMAT_RESET}"
echo

# Loop through each file
for file in "${files[@]}"; do
    # Check if the file is a regular file
    if [ -f "$file" ]; then
        # Get the directory path of the file and the file extension
        directory=$(dirname "$file")
        extension="${file#*.}"
        # Get the MD5 hash of the file
        hash="$(md5sum "$file" | cut -d ' ' -f 1)"
        # Construct the new file name with the MD5 hash and the original extension
        new_name="${directory}/${hash}.${extension}"

        # Check if the script is in check mode
        if [[ "$MODE" == "check" ]]; then
            # Check if file name is already the MD5 hash
            echo "Info: Checking ${file}"
            if [[ "$file" != *"$hash"* ]]; then
                echo -e "${FORMAT_RED}Error: $file is not named with the MD5 hash${FORMAT_RESET}"
                EXIT_CODE=1
            fi
        else
            # Rename the file to the MD5 hash
            # Check if the file name is already the MD5 hash
            if [[ "$file" == "$new_name" ]]; then
                continue
            fi
            # Check if the new file name already exists
            if [ -e "$new_name" ] && [ ! "$OVERWRITE" ]; then
                echo -e "${FORMAT_YELLOW}Warning: $new_name already exists, skipping${FORMAT_RESET}"
                continue
            fi
            # Rename the file to the MD5 hash
            echo "Info: Renaming ${file} to ${new_name}"
            mv "$file" "$new_name"
        fi
    else
        echo "Warning: $file is not a regular file"
    fi
done

echo
echo -e "${FORMAT_GREEN}Info: Done${FORMAT_RESET}"
exit $EXIT_CODE
