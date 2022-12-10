#!/bin/bash

target_dir=$(pwd)
readonly target_dir

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly base_dir

SCRIPT="js"

usage() { 
  echo "Usage: $0 [--stylesheet=(css,sass,scss)] [--script=(js,ts,jsx,tsx)]" 1>&2; 
  exit 1; 
}

set_src () {
    mvc=("models" "views" "controllers")

    # Creates a directory for the mvc elements inside src
    for dir in "${mvc[@]}"; do
        mkdir -p "$target_dir/src/mvc/$dir"
    done

    mkdir "$target_dir/src/routes" && cp "$base_dir/files/routes/index.$SCRIPT" "$target_dir/src/routes/"
}

set_src
