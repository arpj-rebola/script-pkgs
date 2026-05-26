#!/usr/bin/env bash

# script-pkgs init-script
url="https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh"
release="https://api.github.com/repos/laurent22/joplin/releases"
target="/opt/joplin"
tag="$(curl -sL "$release" | jq -eMcr 'map(select(.["prerelease"] | not)) |
    first | .["name"]')" || exit 1

# script-pkgs install-script
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 755 -d "$target" || exit 1
script="$(mktemp)" || exit 1
wget -O "$script" "$url" || exit 1
bash "$script" --silent --install-dir="$target" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    script="$(mktemp)" || exit 1
    wget -O "$script" "$url" || exit 1
    bash "$script" --silent --install-dir="$target" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi