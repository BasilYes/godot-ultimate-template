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

    install "$(cat ./installlist)"
}

install () {
    NL=$'\n'
    IFS=$NL
    list=$1
    selected=""
    if [[ -z $2 ]]; then
        for i in $list;do
            if [[ -z $i ]];then continue; fi
            IFS=' '
            split=($i)
            if [[ -f .submodules ]] && ([[ -z $(cat .submodules | grep split[1]) ]] || [[ -z $(cat .submodules | grep split[2]) ]]); then continue; fi
            read -p "install ${split[1]} to ${split[0]} y/n:" install
            if [[ "$install" == "y" ]] || [[ "$install" == "yes" ]]; then
                if [[ -z selected ]]; then
                    selected="${i}"
                else
                    selected="${selected}${NL}${i}"
                fi
            fi
        done
    else
        selected=$list
    fi
    IFS=$NL
    for i in $selected;do
        IFS=' '
        split=($i)
        if [[ -f .submodules ]] && ([[ -z $(cat .submodules | grep split[1]) ]] || [[ -z $(cat .submodules | grep split[2]) ]]); then continue; fi
        IFS='.'
        name=(${split[1]})
        IFS='/'
        name=(${name[-2]})
        name=${name[-1]}
        path="${split[0]}/${name}"
        git "submodule" "add" "${split[1]}" "$path" ||
        git "submodule" "add" "${split[2]}" "$path"
        path="./${path}/dependencies"
        if [[ -f $path ]];then
            install "$(cat "$path")" yes
        fi
    done

    if [[ -n $selected ]]; then
        git add .
        git commit -m "$(echo -e "add submodules\n${selected[1]}")"
    fi
}

test() {
    echo $@
}

if [[ "$1" = "init" ]];then
    init
elif [[ "$1" = "addon" ]];then
    install "$(cat ./installlist)"
elif [[ "$1" = "template" ]];then
    install template
elif [[ "$1" = "test" ]];then
    test "$(cat ./addonslist)"
fi
