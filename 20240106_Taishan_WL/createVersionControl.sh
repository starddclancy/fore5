#!/bin/bash

INPUT_DIR="$1"

OUTPUT_DIR="$2"

if [ ! -d "$INPUT_DIR" ]; then
    echo "NOT FOUND: $INPUT_DIR"
    exit 1
fi

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

for folder in "$INPUT_DIR"/*; do
    if [ -d "$folder" ]; then
        foldername=$(basename "$folder")
        target_file="$OUTPUT_DIR/versionControl_$foldername.txt"
        touch "$target_file"
        chmod 666 "$target_file"
    fi
done

echo "DONE！"
