#!/usr/bin/env bash

# script-pkgs init-script

# script-pkgs install-script
fingerprint="$(curl -sS https://www.spotify.com/de-en/download/linux/ \
        | jq -McrR 'capture("debian/pubkey_(?<hash>[0-9A-F]*)") | .["hash"]')" \
        || exit 1
keyurl="https://download.spotify.com/debian/pubkey_$fingerprint.gpg"
keypath="/etc/apt/trusted.gpg.d/spotify.gpg"
repourl="http://repository.spotify.com"
repopath="/etc/apt/sources.list.d/spotify.list"
sudo rm -rf  "$keypath" "$repopath" || exit 1
curl -sS "$keyurl" \
    | sudo gpg --dearmor --yes -o "$keypath" \
    || exit 1
echo "deb $repourl stable non-free" \
    | sudo tee "$repopath" \
    || exit 1
sudo pkcon -y refresh || exit 1
sudo apt-get install --yes spotify-client || exit 1
tag="$(apt-cache policy spotify-client | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Installed:\\s+(?<tag>.*)$") | .["tag"]')"
status="installed"

# script-pkgs update-script
tag="$(apt-cache policy spotify-client | jq -McrRs 'split("\n") | .[] |
    capture("^\\s+Candidate:\\s+(?<tag>.*)$") | .["tag"]')"
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    sudo pkcon update spotify-client || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi