#!/usr/bin/env bash

# script-pkgs init-script

# script-pkgs install-script
keystore="/etc/apt/keyrings"
keyring="$keystore/githubcli-archive-keyring.gpg"
repourl="https://cli.github.com/packages"
keyurl="$repourl/githubcli-archive-keyring.gpg"
repolist="/etc/apt/sources.list.d/github-cli.list"
sudo mkdir -p -m 755 "$keystore" || exit 1
sudo rm -f "$keyring" "$repolist" || exit 1
sudo wget -qO- "$keyurl"  \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$keyring" \
    || exit 1
echo "deb [signed-by=$keyring arch=$( dpkg --print-architecture )] $repourl stable main" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$repolist" \
    || exit 1
sudo pkcon -y refresh || exit 1
sudo apt-get install -y gh || exit 1
tag="$(apt-cache policy gh | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')"
status="installed"

# script-pkgs update-script
tag="$(apt-cache policy gh | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Candidate:\\s+(?<tag>.*)$") | .["tag"]')"
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    sudo pkcon update gh || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi
