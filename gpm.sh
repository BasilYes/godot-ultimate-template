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
}

addon () {
    IFS=$'\n'
    addons=""
    for i in $(cat "$SCRIPT_DIR/addonslist");do
        read -p "Add $i y/n:" install
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
        git "submodule" "add" "${i}" "addons/${name}"
    done
    exit 0
    read -p "Add godot-easy-multiplayer y/n:" godot_easy_multiplayer
    read -p "Add godot-transitions y/n:" godot_transitions
    read -p "Add godot-fast-ui y/n:" godot_fast_ui
    read -p "Add godot-simple-saves y/n:" godot_simple_saves
    read -p "Add godot-smart-analycis y/n:" godot_smart_analycis
    read -p "Add godot-ads-manager y/n:" godot_ads_manager
    message="add addon "
    if [[ "$godot_easy_multiplayer" == "y" ]] || [[ "$godot_easy_multiplayer" == "yes" ]]; then
        commit=true
        message="${message} godot-easy-multiplayer"
        git submodule add git@github.com:FeatureKillersGames/godot-easy-multiplayer.git addons/godot-easy-multiplayer
    fi
    if [[ "$godot_transitions" == "y" ]] || [[ "$godot_transitions" == "yes" ]]; then
        commit=true
        message="${message} godot-transitions"
    fi
    if [[ "$godot_fast_ui" == "y" ]] || [[ "$godot_fast_ui" == "yes" ]]; then
        commit=true
        message="${message} godot-fast-ui"
        git submodule add git@github.com:FeatureKillersGames/godot-fast-ui.git addons/godot-fast-ui
    fi
    if [[ "$godot_simple_saves" == "y" ]] || [[ "$godot_simple_saves" == "yes" ]]; then
        commit=true
        message="${message} godot-simple-saves"
        git submodule add git@github.com:FeatureKillersGames/godot-simple-saves.git addons/godot-simple-saves
    fi
    if [[ "$godot_smart_analycis" == "y" ]] || [[ "$godot_smart_analycis" == "yes" ]]; then
        commit=true
        message="${message} godot-smart-analycis"
        git submodule add git@github.com:FeatureKillersGames/godot-smart-analycis.git addons/godot-smart-analycis
    fi
    if [[ "$godot_ads_manager" == "y" ]] || [[ "$godot_ads_manager" == "yes" ]]; then
        commit=true
        message="${message} godot-ads-manager"
        git submodule add git@github.com:FeatureKillersGames/godot-ads-manager.git addons/godot-ads-manager
    fi
    if [[ -n $commit ]]; then
        git add .
        git commit -m $message
    fi
}

if [[ "$1" = "init" ]];then
    init
elif [[ "$1" = "addon" ]];then
    addon
fi
