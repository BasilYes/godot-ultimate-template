#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

mkdir -p $SCRIPT_DIR/assets/gdignore
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
read -p "Add godot-easy-multiplayer y/n:" yesorno
if [[ "$yesorno" == "y" ]] || [[ "$yesorno" == "yes" ]]; then
    git submodule add git@github.com:FeatureKillersGames/godot-easy-multiplayer.git addons/godot-easy-multiplayer
fi
read -p "Add godot-transitions y/n:" yesorno
if [[ "$yesorno" == "y" ]] || [[ "$yesorno" == "yes" ]]; then
    git submodule add git@github.com:FeatureKillersGames/godot-transitions.git addons/godot-transitions
fi
read -p "Add godot-fast-ui y/n:" yesorno
if [[ "$yesorno" == "y" ]] || [[ "$yesorno" == "yes" ]]; then
    git submodule add git@github.com:FeatureKillersGames/godot-fast-ui.git addons/godot-fast-ui
fi
read -p "Add godot-simple-saves y/n:" yesorno
if [[ "$yesorno" == "y" ]] || [[ "$yesorno" == "yes" ]]; then
    git submodule add git@github.com:FeatureKillersGames/godot-simple-saves.git addons/godot-simple-saves
fi
git add .
git commit -m "init"
git reset $(git commit-tree "HEAD^{tree}" -m "init")
git remote remove origin
