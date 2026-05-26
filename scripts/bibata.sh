#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
slug="ful1e5/Bibata_Cursor"
ghreleases="https://api.github.com/repos/$slug/releases"
tag="$(curl -sL "$ghreleases" | jq -eMcr 'first | .["tag_name"]')" || exit 1

# script-pkgs install-script
url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
    .["assets"] | .[] | select(.["name"] == "Bibata.tar.xz") | .["browser_download_url"]')" || exit 1
tar="$(mktemp)" || exit 1
wget -O "$tar" "$url" || exit 1
# shellcheck disable=SC2174
mkdir -p -m 775 "$HOME/.icons" || exit 1
rm -rf "$HOME/.icons/Bibata-"* || exit 1
tar -C "$HOME/.icons" -xf "$tar" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
        .["assets"] | .[] | select(.["name"] == "Bibata.tar.xz") | .["browser_download_url"]')" || exit 1
    tar="$(mktemp)" || exit 1
    wget -O "$tar" "$url" || exit 1
    rm -rf "$HOME/.icons/Bibata-"* || exit 1
    tar -C "$HOME/.icons" -xf "$tar" || exit 1
    kcminit mouse || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi