#!/usr/bin/env bash

# script-pkgs init-script
slug="tamarin-prover/tamarin-prover"
ghreleases="https://api.github.com/repos/$slug/releases"
tag="$(curl -sL "$ghreleases" | jq -eMcr 'first | .["tag_name"]')" || exit 1
target="/opt/tamarin"

# script-pkgs install-script
url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" \
    '.[] | select(.["tag_name"] == $tag) |
    .["assets"] | .[] | select(.["name"] |
    test("^tamarin-prover-[0-9\\.]+-linux64-ubuntu\\.tar\\.gz$")) |
    .["browser_download_url"]')" || exit 1
targz="$(mktemp)" || exit 1
wget -qO "$targz" "$url" || exit 1
sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
tar -C "$target" -xf "$targz" || exit 1
sudo ln -fs "$target/tamarin-prover" "/usr/bin/tamarin" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" \
        '.[] | select(.["tag_name"] == $tag) |
        .["assets"] | .[] | select(.["name"] |
        test("^tamarin-prover-[0-9\\.]+-linux64-ubuntu\\.tar\\.gz$")) |
        .["browser_download_url"]')" || exit 1
    targz="$(mktemp)" || exit 1
    wget -qO "$targz" "$url" || exit 1
    sudo rm "$target/tamarin-prover"
    tar -C "$target" -xf "$targz" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi