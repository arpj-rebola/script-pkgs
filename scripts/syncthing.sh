#!/usr/bin/env bash

# script-pkgs init-script

# script-pkgs install-script
keystore="/etc/apt/keyrings"
keyring="$keystore/syncthing-archive-keyring.gpg"
keyurl="https://syncthing.net/release-key.gpg"
repourl="https://apt.syncthing.net/"
repolist="/etc/apt/sources.list.d/syncthing.list"
# desktopsrc="/usr/share/applications/syncthing-start.desktop"
# desktopdest="$HOME/.config/autostart/syncthing-start.desktop"
sudo mkdir -p -m 755 "$keystore" || exit 1
sudo wget -qO- "$keyurl" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$keyring" \
    || exit 1
echo "deb [signed-by=$keyring] $repourl syncthing stable" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$repolist" \
    || exit 1
sudo pkcon -y refresh || exit 1
sudo apt-get install -y syncthing || exit 1
# mkdir -p "$(dirname "$desktopsrc")" || exit 1
# cp -f "$desktopsrc" "$desktopdest" || exit 1
# systemctl --user enable syncthing.service || exit 1
tag="$(apt-cache policy syncthing | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')"
status="installed"

# script-pkgs update-script
tag="$(apt-cache policy syncthing | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Candidate:\\s+(?<tag>.*)$") | .["tag"]')"
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    # systemctl --user stop syncthing.service || exit 1
    sudo pkcon update syncthing || exit 1
    # systemctl --user start syncthing.service || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi