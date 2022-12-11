#!/bin/bash

usage() {
    echo -e "usage: $0 [OPTION]\n"
}

example() {
    echo -e "example: $0 -css=sass --script=ts -n=repo_name"
    exit 0
}

help() {
  usage
    echo -e "OPTION:"
    echo -e "  -css=, --stylesheet=   [css, sass, scss]"
    echo -e "  -scr=, --script=   [js, ts]"
    echo -e "  -n=, --name=   Name of the project. Default is $REPO_NAME"
    echo -e "  -h,  --help    Prints this help\n"
  example
}

compiled=("sass" "scss" "ts")
readonly compiled

SCRIPT="js"
STYLESHEETS="css"
REPO_NAME="node_express"

for i in "$@"; do
    case $i in
        --stylesheet=* | -css=*)
            value="${i#*=}"
            possibilities=("css" "sass" "scss")

            ! [[ ${possibilities[*]} =~ ${value} ]] && break

            STYLESHEETS="$value"
            shift ;;

        --script=* | -scr=*)
            value="${i#*=}"
            possibilities=("js" "ts")

            ! [[ ${possibilities[*]} =~ ${value} ]] && break

            SCRIPT="$value"
            shift ;;
            
        --name=* | -n=*)
            value="${i#*=}"

            REPO_NAME="$value"
            shift ;;

        --help | -h )
            help
            shift ;;

        *)
            break ;;
    esac

done

target_dir="$(pwd)/$REPO_NAME"
readonly target_dir

base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly base_dir

if [[ -d "$target_dir" ]]; then  
    echo "$REPO_NAME already exists"
    exit 0
else
    echo "creating $REPO_NAME"
fi

mkdir "$target_dir"

# Checks if array contains certain value
# usage: array_contains [array] [value]
array_contains() { 
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

# Configs the root folder of the app
set_app () {
    # Options for the build and watch scripts in package.json
    declare -A build_options
    build_options["ts"]="tsc -p ."
    build_options["sass"]="node-sass --include-path sass .\/src\/styles\/styles.css .\/dist\/styles\/styles.$STYLESHEETS"
    build_options["ts-sass"]="${build_options[ts]} && ${build_options[sass]}"
    build_options["default"]="cp -r src\/ dist\/"

    echo "${build_options[ts-sass]}"
    # exit 0

    local watch_all="nodemon -e $STYLESHEETS,$SCRIPT -x 'npm run build'"

    # If the SCRIPT or STYLESHEETS are compiled, compile them after each change
    # if array_contains compiled "$SCRIPT" || array_contains compiled "$STYLESHEETS"; then
    #     watch_all="nodemon -e $STYLESHEETS,$SCRIPT"
    # fi

    cp "$base_dir/files/package.json" "$target_dir"

    sed -i "s/<----PLACEHOLDER WATCH---->/$watch_all/g" "$target_dir/package.json"

    # Adds tsconfig if ts is chosen
    [[ $SCRIPT == "ts" ]] && cp "$base_dir/files/tsconfig.json" "$target_dir"

    # It's ugly, but i cannot think of a better method
    if [[ ($STYLESHEETS == "sass" || $STYLESHEETS == "scss") && $SCRIPT == "ts" ]]; then
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[ts-sass]}/g" "$target_dir/package.json"
    elif [[ $STYLESHEETS == "sass" || $STYLESHEETS == "scss" ]]; then
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[sass]}/g" "$target_dir/package.json"
    elif [[ $SCRIPT == "ts" ]]; then
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[ts]}/g" "$target_dir/package.json"
    else
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[default]}/g" "$target_dir/package.json"
    fi
    
    cd "$REPO_NAME" || return

    npm i express
    npm i nodemon -D

    # TODO: install packages necessary
    if [[ $STYLESHEETS == "sass" || $STYLESHEETS == "scss" ]]; then
        echo "Installing $STYLESHEETS dependencies"
        echo ""
        npm i node-sass -D
    fi

    if [[ $SCRIPT == "ts" ]]; then
        echo "Installing ts dependencies"
        npm i typescript ts-node @types/node @types/express -D
    fi
    
    cd "../"

    sed -i "s/<----PLACEHOLDER SCRIPT---->/$SCRIPT/g" "$target_dir/package.json"
    sed -i "s/<----PLACEHOLDER NAME---->/$REPO_NAME/g" "$target_dir/package.json"
}

set_src () {
    local mvc=("models" "views" "controllers")

    # Creates a directory for the mvc elements inside src
    for dir in "${mvc[@]}"; do
        mkdir -p "$target_dir/src/mvc/$dir"
    done

    # Creates the routes and the styles dir and initialize them
    mkdir "$target_dir/src/routes" && cp "$base_dir/files/routes/index.$SCRIPT" "$target_dir/src/routes/"
    mkdir "$target_dir/src/styles" && cp "$base_dir/files/styles/styles.css" "$target_dir/src/styles/styles.$STYLESHEETS"

    # Copies the application to the project's src
    cp "$base_dir/files/app.$SCRIPT" "$target_dir/src/"

}

set_app

set_src
