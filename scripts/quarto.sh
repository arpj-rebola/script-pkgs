#!/usr/bin/env bash

# script-pkgs init-script
slug="quarto-dev/quarto-cli"
releases="https://api.github.com/repos/$slug/releases"
tag="$(curl -sL --header "Authorization: Bearer $GITHUB_TOKEN" --url "$releases" \
    | jq -eMcr 'first | .["tag_name"]')" || exit 1

# script-pkgs install-script
url="$(curl -sL --header "Authorization: Bearer $GITHUB_TOKEN" --url "$releases" \
    | jq -eMcr --arg tag "$tag" \
    '.[] | select(.["tag_name"] == $tag) |
    .["assets"] | .[] | select(.["name"] |
    test("^quarto-[0-9\\.]+-linux-amd64.deb$")) |
    .["browser_download_url"]')" || exit 1
deb="$(mktemp)" || exit 1
wget -qO "$deb" "$url" || exit 1
sudo dpkg -i "$deb" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    url="$(curl -sL --header "Authorization: Bearer $GITHUB_TOKEN" --url "$releases" \
        | jq -eMcr --arg tag "$tag" --arg ubuntuid "$ubuntuid" \
        '.[] | select(.["tag_name"] == $tag) |
        .["assets"] | .[] | select(.["name"] |
        test("^ubuntu-" + $ubuntuid + "-cbmc-.*-Linux\\.deb$")) |
        .["browser_download_url"]')" || exit 1
    deb="$(mktemp)" || exit 1
    wget -qO "$deb" "$url" || exit 1
    sudo dpkg -i "$deb" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi