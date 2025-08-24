#!/bin/bash

# This script generates the `Globals.inc` file from the `RAM.asm` file.

# Why is this needed?
# The `Ram.asm` file is missing labels for many memory addresses.
# Adding these missing labels is part of the ongoing work on this project.
# When a label is added, it needs to be exported from `Ram.asm` and imported into each other file that wants to reference it.
# Instead of using `.export myLabel` and `.import myLabel`, we can use `.global myLabel` instead for both, and the compiler will detect if it needs to export or import.
# This allows us to use a single file `Globals.inc` that contains all the `.global` directives and use `.include "Globals.inc"` everywhere.

# Usage:
# ./helper_programs/generate_globals.sh

# When to run:
# Whenever a new label has been added to `RAM.asm`.

WATCH_MODE=false

case "$1" in
    --watch)
        WATCH_MODE=true
        ;;
    *)
        if [[ -n "$1" ]]; then
            echo "Unknown option: $1"
            exit 1
        fi
        ;;
esac

generate_globals() {
    local ram_file="$1"
    local globals_file="$2"

    # Clear the output file
    > "$globals_file"

    # This controls the directive used to share the current label
    #   ".globalzp myLabel" for zeropage addresses
    #   ".global   myLabel" for everything else
    local directive=".global"

    # Read the RAM file and process each line
    local globalCount=0
    while IFS= read -r line; do

        # Detect which directive needs to be output based on the current segment
        if [[ $line =~ ^\.zeropage ]]; then
            directive=".globalzp"
        elif [[ $line =~ ^\.(bss|segment) ]]; then
            directive=".global"
        fi

        # Find lines matching "myLabel : ..." and output ".global myLabel"
        if [[ $line =~ ^[[:space:]]*([[:alnum:]_]+)[[:space:]]*: ]]; then
            label="${BASH_REMATCH[1]}"

            # Append to output file
            echo "$directive $label" >> "$globals_file"
            ((globalCount++))
        fi
    done < "$ram_file"
    echo "Globals: ${globalCount}"
}

generate_globals "source_files/RAM.asm" "source_files/Globals.inc"

if [[ "$WATCH_MODE" == true ]]; then
    while true; do
        inotifywait -e modify,create,delete -r "source_files/RAM.asm"
        generate_globals "source_files/RAM.asm" "source_files/Globals.inc"
    done
fi
