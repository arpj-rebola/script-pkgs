#!/usr/bin/env bash

# script-pkgs init-script

# script-pkgs install-script
keystore="/etc/apt/keyrings"
keyring="$keystore/packages.microsoft.gpg"
repourl="https://packages.microsoft.com/repos/code"
keyurl="https://packages.microsoft.com/keys/microsoft.asc"
repolist="/etc/apt/sources.list.d/vscode.list"
sudo mkdir -p -m 755 "$keystore" || exit 1
sudo rm -f "$keyring" "$repolist" || exit 1
wget -qO- "$keyurl" | gpg --dearmor \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$keyring" \
    || exit 1
echo "deb [arch=$( dpkg --print-architecture ) signed-by=$keyring] $repourl stable main" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$repolist" \
    || exit 1
sudo pkcon -y refresh || exit 1
sudo apt-get install -y code || exit 1
tag="$(apt-cache policy code | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')"
status="installed"

# script-pkgs update-script
tag="$(apt-cache policy code | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Candidate:\\s+(?<tag>.*)$") | .["tag"]')"
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    sudo pkcon update code || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi