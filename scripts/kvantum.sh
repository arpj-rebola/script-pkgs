#!/usr/bin/env bash

# script-pkgs init-script

# script-pkgs install-script
keystore="/etc/apt/keyrings"
ppaurl="https://launchpad.net/~papirus/+archive/ubuntu/papirus"
keyurl="https://keyserver.ubuntu.com/pks/lookup?op=get"
fingerprint="$(curl -sL "$ppaurl" | jq -McrRs 'capture("<script id=\"json-cache-script\">(?<cache>[^<]*)</script>") |
    .["cache"] | capture("^[^=\\s]+\\s*=\\s*(?<json>.*);$") | .["json"] |
    fromjson | .["context"] | .["signing_key_fingerprint"]')" || exit 1
keyring="$keystore/papirus.gpg"
repourl="https://ppa.launchpadcontent.net/papirus/papirus/ubuntu"
repolist="/etc/apt/sources.list.d/papirus.list"
sudo mkdir -p -m 755 "$keystore" || exit 1
sudo rm -rf  "$keyring" "$repolist" || exit 1
curl -sL "$keyurl&search=0x$fingerprint" \
    | sudo gpg --dearmor --yes \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$keyring" \
    || exit 1
echo "deb [signed-by=$keyring arch=$(dpkg --print-architecture)] $repourl $(lsb_release -cs) main" \
    | sudo install -o "root" -g "root" -m 644 "/dev/stdin" "$repolist" \
    || exit 1
sudo pkcon refresh || exit 1
sudo apt-get install -y qt6-style-kvantum || exit 1
tag="$(apt-cache policy qt6-style-kvantum | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')"
status="installed"

# script-pkgs update-script
tag="$(apt-cache policy qt6-style-kvantum | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')"
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    sudo pkcon update qt6-style-kvantum || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi
