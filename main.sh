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

# Usage: rename_extensions current_extension desired_extension
rename_extensions() {
    # Dunno how to make this work
    # find . -name "*.$1" -exec sh -c "mv '${}' ${0%.js}.cjs" {} \;

    # So i'll use this
    find "$target_dir/src" -iname "*.$1" -exec rename "s/\.$1$/\.$2/i" {} \;
}


# compiled=("sass" "scss" "ts")
# readonly compiled

SCRIPT="js"
STYLESHEETS="css"
REPO_NAME="node_express"

for i in "$@"; do
    case $i in
        # Gets the value after the options and check if it's valid
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
    echo ""
    echo "creating $REPO_NAME"
    echo ""
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
    local compile_sass="node-sass --include-path sass .\/src\/styles\/styles.$STYLESHEETS .\/dist\/styles\/styles.css"
    local compile_ts="tsc -p ."

    declare -A build_options
    
    # todo: not working  <13-12-22, yourname> #
    build_options["ts"]="$compile_ts \&\& rsync -av --progress src\/styles\/ dist\/styles\/"
    # Compiles sass and copies other files in src folder, only if they were modified
    build_options["sass"]="rsync -av --progress src\/ dist\/ --exclude \/styles\/ \&\& $compile_sass"
    build_options["ts-sass"]="$compile_ts \&\& $compile_sass"
    build_options["default"]="rsync -av --progress src\/ dist\/"

    local watch_all="nodemon -e $STYLESHEETS,$SCRIPT -x 'npm run build'"

    # If the SCRIPT or STYLESHEETS are compiled, compile them after each change
    # if array_contains compiled "$SCRIPT" || array_contains compiled "$STYLESHEETS"; then
    #     watch_all="nodemon -e $STYLESHEETS,$SCRIPT"
    # fi

    cp "$base_dir/files/package.json" "$target_dir"

    sed -i "s/<----PLACEHOLDER WATCH---->/$watch_all/g" "$target_dir/package.json"

    # Adds tsconfig if ts is chosen
    [[ $SCRIPT == "ts" ]] && cp "$base_dir/files/tsconfig.json" "$target_dir"

    cd "$REPO_NAME" || return

    npm i express
    npm i nodemon -D

    if [[ $STYLESHEETS == "sass" || $STYLESHEETS == "scss" ]]; then
        echo ""
        echo "Installing $STYLESHEETS dependencies..."
        echo ""
        npm i node-sass -D
        mkdir -p "$target_dir/dist/styles"
    fi

    if [[ $SCRIPT == "ts" ]]; then
        echo ""
        echo "Installing ts dependencies..."
        echo ""
        npm i typescript ts-node @types/node @types/express -D
    fi

    cd "../"

    sed -i "s/<----PLACEHOLDER SCRIPT---->/$SCRIPT/g" "$target_dir/package.json"
    sed -i "s/<----PLACEHOLDER NAME---->/$REPO_NAME/g" "$target_dir/package.json"

    # It's ugly, but i cannot think of a better method
    if [[ ($STYLESHEETS == "sass" || $STYLESHEETS == "scss") && $SCRIPT == "ts" ]]; then
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[ts-sass]}/g" "$target_dir/package.json"
    elif [[ $STYLESHEETS == "sass" || $STYLESHEETS == "scss" ]]; then
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[sass]}/g" "$target_dir/package.json"
    elif [[ $SCRIPT == "ts" ]]; then
        echo only ts
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[ts]}/g" "$target_dir/package.json"
    else
        sed -i "s/<----PLACEHOLDER BUILD---->/${build_options[default]}/g" "$target_dir/package.json"
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
    mkdir "$target_dir/src/styles" && cp "$base_dir/files/styles/styles.css" "$target_dir/src/styles/styles.$STYLESHEETS"

    # Copies the application to the project's src
    cp "$base_dir/files/app.$SCRIPT" "$target_dir/src/"
}

set_src

set_app

echo ""
echo "-----     To see the initial setup, run     -----"
echo ""
echo "-----     cd ${REPO_NAME}     -----"
echo ""
echo "-----     npm run build     -----"
echo ""
echo "-----     npm start     -----"
echo ""
