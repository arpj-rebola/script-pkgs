#!/usr/bin/env bash

# script-pkgs init-script
slug="Z3Prover/z3"
ghreleases="https://api.github.com/repos/$slug/releases"
tag="$(curl -sL "$ghreleases" | jq -Mcr 'map(.["tag_name"] | select(test("^z3-[0-9\\.]+$"))) | first')" || exit 1
target="/opt/z3"

# script-pkgs install-script
url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
    .["assets"] | .[] | select(.["name"] | test("^z3-.*-x64-glibc-.*\\.zip$")) |
    .["browser_download_url"]')" || exit 1
zip="$(mktemp)" || exit 1
tempdir="$(mktemp -d)" || exit 1
wget -qO "$zip" "$url" || exit 1
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
unzip "$zip" -d "$tempdir" || exit 1
path="$(ls "$tempdir")" || exit 1
mv "$tempdir/$path"/* "$target" || exit 1
sudo ln -fs "$target/bin/z3" "/usr/bin/z3" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
        .["assets"] | .[] | select(.["name"] | test("^z3-.*-x64-glibc-.*\\.zip$")) |
        .["browser_download_url"]')" || exit 1
    zip="$(mktemp)" || exit 1
    tempdir="$(mktemp -d)" || exit 1
    wget -qO "$zip" "$url" || exit 1
    sudo rm -rf "$target" || exit 1
    sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
    unzip "$zip" -d "$tempdir" || exit 1
    path="$(ls "$tempdir")" || exit 1
    mv "$tempdir/$path"/* "$target" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi