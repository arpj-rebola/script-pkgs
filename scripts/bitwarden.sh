#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
slug="bitwarden/clients"
ghreleases="https://api.github.com/repos/$slug/releases"
tag="$(curl -sL "$ghreleases" | jq -Mcr \
    'map(select(.["tag_name"] | startswith("cli-"))) | first | .["tag_name"]')" || exit 1
target="/opt/bitwarden-cli"

# script-pkgs install-script
url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
    .["assets"] | .[] | select(.["name"] | test("^bw-linux-[0-9\\.]+\\.zip$")) |
    .["browser_download_url"]')" || exit 1
zip="$(mktemp)" || exit 1
wget -O "$zip" "$url" || exit 1
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
unzip "$zip" -d "$target" || exit 1
sudo ln -fs "$target/bw" "/usr/bin/bw" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
        .["assets"] | .[] | select(.["name"] | test("^bw-linux-[0-9\\.]+\\.zip$")) |
        .["browser_download_url"]')" || exit 1
    zip="$(mktemp)" || exit 1
    wget -O "$zip" "$url" || exit 1
    sudo rm -rf "$target" || exit 1
    sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
    unzip "$zip" -d "$target" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi
