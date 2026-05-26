#!/usr/bin/env bash

# script-pkgs init-script
download="https://zoom.us/client/latest/zoom_amd64.deb"
tag="$(curl -sI "$download" | jq -Rs 'split("\n") | .[] |
    capture("^location:\\s*(?<url>.*\\.deb)") | .["url"] | split("/") | .[4]')" || exit 1

# script-pkgs install-script
deb="$(mktemp)" || exit 1
fixed="$(mktemp -d)" || exit 1
wget -O "$deb" "$download" || exit 1
dpkg -x "$deb" "$fixed" || exit 1
dpkg -e "$deb" "$fixed/DEBIAN" || exit 1
sed -i -E 's/(ibus, |, ibus)//' "$fixed/DEBIAN/control" || exit 1
dpkg -b "$fixed" "$deb" || exit 1
rm -rf "$fixed" || exit 1
sudo dpkg -i "$deb" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    deb="$(mktemp)" || exit 1
    fixed="$(mktemp -d)" || exit 1
    wget -O "$deb" "$download" || exit 1
    dpkg -x "$deb" "$fixed" || exit 1
    dpkg -e "$deb" "$fixed/DEBIAN" || exit 1
    sed -i -E 's/(ibus, |, ibus)//' "$fixed/DEBIAN/control" || exit 1
    dpkg -b "$fixed" "$deb" || exit 1
    rm -rf "$fixed" || exit 1
    sudo dpkg -i "$deb" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi