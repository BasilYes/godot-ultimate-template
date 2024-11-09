#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

init () {
    mkdir -p $SCRIPT_DIR/addons
    mkdir -p $SCRIPT_DIR/assets/gdignore
    touch $SCRIPT_DIR/assets/gdignore/.gdignore
    mkdir -p $SCRIPT_DIR/assets/sounds
    mkdir -p $SCRIPT_DIR/assets/textures
    mkdir -p $SCRIPT_DIR/assets/textures/ui
    mkdir -p $SCRIPT_DIR/assets/translations
    mkdir -p $SCRIPT_DIR/build/android
    mkdir -p $SCRIPT_DIR/build/linux
    mkdir -p $SCRIPT_DIR/build/web
    mkdir -p $SCRIPT_DIR/build/win
    touch $SCRIPT_DIR/build/.gdignore
    mkdir -p $SCRIPT_DIR/resources/materials
    mkdir -p $SCRIPT_DIR/resources/meshes
    mkdir -p $SCRIPT_DIR/resources/shaders
    mkdir -p $SCRIPT_DIR/resources/themes
    mkdir -p $SCRIPT_DIR/scenes
    mkdir -p $SCRIPT_DIR/scripts
    git init
    git add .
    git commit -m "init"
    git reset $(git commit-tree "HEAD^{tree}" -m "init")
    git remote remove origin

    install addon
    install template
}

install () {
    IFS=$'\n'
    addons=""
    for i in $(cat "$SCRIPT_DIR/${1}slist");do
        read -p "install $1 $i y/n:" install
        if [[ "$install" == "y" ]] || [[ "$install" == "yes" ]]; then
            addons="${addons}\n${i}"
        fi
    done
    addons=($(echo -e $addons))
    for i in ${addons[*]};do
        IFS=$'.'
        name=($i)
        IFS=$'/'
        name=(${name[-2]})
        name=${name[-1]}
        git "submodule" "add" "${i}" "${1}s/${name}"
    done

    if [[ -n $addons ]]; then
        git add .
        git commit -m "$(echo -e "add submodules\n${addons[*]}")"
    fi
}

if [[ "$1" = "init" ]];then
    init
elif [[ "$1" = "addon" ]];then
    install addon
elif [[ "$1" = "template" ]];then
    install template
fi
