#!/usr/bin/env bash

# script-pkgs init-script

# script-pkgs install-script
keystore="/usr/share/keyrings"
keyring="$keystore/tailscale-archive-keyring.gpg"
repolist="/etc/apt/sources.list.d/tailscale.list"
slug="https://pkgs.tailscale.com/stable/ubuntu"
ubuntuid="$(bash -c 'source /etc/os-release; echo -n "$VERSION_ID"')" || exit 1
keyurl="$slug/$ubuntuid.noarmor.gpg"
repourl="$slug/$ubuntuid.tailscale-keyring.list"
sudo mkdir -p -m 755 "$keystore" || exit 1
wget -O- "$keyurl" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$keyring" \
    || exit 1
wget -O- "$repourl" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$repolist" \
    || exit 1
sudo pkcon -y refresh || exit 1
sudo apt-get install -y tailscale  || exit 1
tag="$(apt-cache policy tailscale | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')" || exit 1
status="installed"

# script-pkgs update-script
tag="$(apt-cache policy tailscale | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Candidate:\\s+(?<tag>.*)$") | .["tag"]')"
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    sudo pkcon update tailscale || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi