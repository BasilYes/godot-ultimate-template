#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

create_dirs () {
    mkdir -p $SCRIPT_DIR/templates
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
}

init () {
    create_dirs
    IFS='/'
    script_path=($SCRIPT_DIR)
    sed -i "s@godot-ultimate-template@${script_path[-1]}@g" ./project.godot
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
            if [[ -f .submodules ]] && ([[ -z $(cat .submodules | grep ${split[1]}) ]] || [[ -z $(cat .submodules | grep ${split[2]}) ]]); then continue; fi
            # Get the default method from the installlist (3rd column) or use "m" if not specified
            default_method="${split[3]:-m}"
            read -p "install ${split[1]} to ${split[0]} using sub(m)odule or (c)lone enter for ${default_method} [m/c/n]:" install
            # If user just pressed enter, use the default method
            if [[ -z "$install" ]]; then
                install="$default_method"
            fi
            if [[ "$install" == "m" ]] || [[ "$install" == "c" ]]; then
                if [[ -z $selected ]]; then
                    selected="${split[0]} ${split[1]} ${split[2]} $install"
                else
                    selected="${selected}${NL}${split[0]} ${split[1]} ${split[2]} $install"
                fi
            fi
        done
    else
        selected=$list
    fi
    IFS=$NL
    commit=""
    for i in $selected;do
        IFS=' '
        split=($i)
        if [[ -f .submodules ]] && ([[ -z $(cat .submodules | grep ${split[1]}) ]] || [[ -z $(cat .submodules | grep ${split[2]}) ]]); then continue; fi
        IFS='.'
        name=(${split[1]})
        IFS='/'
        name=(${name[-2]})
        name=${name[-1]}
        path="${split[0]}/${name}"

        # Check if addon is already installed
        if [[ -d "$path" ]]; then
            echo "Addon already installed at $path, skipping..."
            continue
        fi

        # Default to submodule if method not specified
        method=${split[3]:-"m"}

        if [[ "$method" == "m" ]]; then
            # Install as submodule
            git "submodule" "add" "${split[1]}" "$path" ||
            git "submodule" "add" "${split[2]}" "$path"
            commit_msg="add submodule"
        elif [[ "$method" == "c" ]]; then
            # Install as clone (instead of subtree) - only get the last commit
            repo_url=${split[1]}
            # Try the first URL, if it fails try the second URL
            if ! git clone --depth 1 "${repo_url}" "$path"; then
                git clone --depth 1 "${split[2]}" "$path"
            fi
            
            # Remove git directory to detach from original repo
            rm -rf "$path/.git"
            
            # Add the directory to our repo
            git add "$path"
            commit_msg="add clone"
        fi

        commit="${commit}${NL}${path}"
        path="./${path}/dependencies"
        if [[ -f $path ]];then
            install "$(cat "$path")" yes
        fi
    done

    if [[ -n $selected ]]; then
        git add .
        git commit -m "$(echo -e "${commit_msg}\n${commit}")"
    fi
}

test() {
    echo $@
}

if [[ "$1" = "init" ]];then
    init
elif [[ "$1" = "dirs" ]];then
    create_dirs
elif [[ "$1" = "install" ]];then
    # If method is explicitly provided, use it
    if [[ "$3" = "clone" ]] || [[ "$3" = "c" ]]; then
        method="c"
    elif [[ "$3" = "submodule" ]] || [[ "$3" = "m" ]]; then
        method="m"
    else
        # If no method specified in command line, use the one from installlist
        method=""
    fi
    install "$(cat ./installlist | grep $2) $method"
fi
