#!/bin/bash

target_dir=$(pwd)
readonly target_dir

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly base_dir

compiled=("sass" "scss" "ts")
readonly compiled

SCRIPT="js"
STYLESHEETS="css"

usage() { 
    echo "Usage: $0 [--stylesheet=(css,sass,scss)] [--script=(js,ts,jsx,tsx)]" 1>&2; 
    exit 1; 
}

array_contains () { 
    local array="$1[@]"
    local seeking=$2

    local in=1
    for element in "${!array}"; do
        if [[ $element == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

set_app () {
    # Options for the build and watch scripts in package.json
    declare -A build_options
    build_options["ts"]="tsc -p ."
    build_options["sass"]="node-sass --include-path sass ./src/styles/styles.css ./dist/styles/styles.$STYLESHEETS"

    local watch_all="nodemon -e $STYLESHEETS,$SCRIPT"

    # If the SCRIPT or STYLESHEETS are compiled, compile them after each change
    if array_contains compiled "$SCRIPT" || array_contains compiled "$STYLESHEETS"; then
        watch_all="nodemon -e $STYLESHEETS,$SCRIPT -x 'npm run build'"
    fi

    # Adds tsconfig if ts is chosen
    [[ $SCRIPT == "ts" ]] && cp "$base_dir/files/tsconfig.json" "$target_dir"

    # TODO: install packages necessary
    if [[ $STYLESHEETS == "sass" || $STYLESHEETS == "scss" ]]; then
        echo
    fi

    if [[ $SCRIPT == "ts" ]]; then
        echo
    fi

}


set_src () {
    local mvc=("models" "views" "controllers")

    # Creates a directory for the mvc elements inside src
    for dir in "${mvc[@]}"; do
        mkdir -p "$target_dir/src/mvc/$dir"
    done

    # Creates the routes and the styles dir and initialize them
    mkdir "$target_dir/src/routes" && cp "$base_dir/files/routes/index.$SCRIPT" "$target_dir/src/routes/"
    mkdir "$target_dir/src/styles" && cp "$base_dir/files/styles/styles.$STYLESHEETS" "$target_dir/src/styles/"

    # Copies the application to the project's src
    cp "$base_dir/files/app.$SCRIPT" "$target_dir/src/"

}

set_app

set_src
