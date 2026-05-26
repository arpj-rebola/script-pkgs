#!/usr/bin/env bash

# script-pkgs init-script
api="https://discord.com/api"
updates="$api/updates/stable?platform=linux"
download="$api/download?platform=linux&format=deb"
tag="$(curl -sL "$updates" | jq -eMcr '.["name"]')" || exit 1

# script-pkgs install-script
deb="$(mktemp)" || exit 1
wget -O "$deb" "$download" || exit 1
sudo dpkg -i "$deb" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    deb="$(mktemp)" || exit 1
    wget -O "$deb" "$download" || exit 1
    sudo dpkg -i "$deb" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi

