#!/usr/bin/env bash

# script-pkgs init-script

# script-pkgs install-script
keystore="/usr/share/keyrings"
keyring="$keystore/mullvad-keyring.asc"
keyurl="https://repository.mullvad.net/deb/mullvad-keyring.asc"
repourl="https://repository.mullvad.net/deb/stable"
repolist="/etc/apt/sources.list.d/mullvad.list"
sudo mkdir -p -m 755 "$keystore" || exit 1
wget -O- "$keyurl" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$keyring" \
    || exit 1
echo "deb [signed-by=$keyring arch=$( dpkg --print-architecture )] $repourl $(lsb_release -cs) main" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$repolist" \
    || exit 1
sudo pkcon -y refresh || exit 1
sudo apt-get install -y mullvad-vpn || exit 1
tag="$(apt-cache policy mullvad-vpn | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')"
status="installed"

# script-pkgs update-script
tag="$(apt-cache policy mullvad-vpn | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Candidate:\\s+(?<tag>.*)$") | .["tag"]')"
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    sudo pkcon update mullvad-vpn || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi