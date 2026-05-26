#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
slug="diffblue/cbmc"
ghreleases="https://api.github.com/repos/$slug/releases"
tag="$(curl -sL "$ghreleases" | jq -eMcr 'first | .["tag_name"]')" || exit 1
ubuntuid="$(bash -c 'source /etc/os-release; echo -n "$VERSION_ID"' | sed 's+\.+\\.+g')" || exit 1

# script-pkgs install-script
url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" --arg ubuntuid "$ubuntuid" \
    '.[] | select(.["tag_name"] == $tag) |
    .["assets"] | .[] | select(.["name"] |
    test("^ubuntu-" + $ubuntuid + "-cbmc-.*-Linux\\.deb$")) |
    .["browser_download_url"]')" || exit 1
deb="$(mktemp)" || exit 1
wget -qO "$deb" "$url" || exit 1
sudo dpkg -i "$deb" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    url="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" --arg ubuntuid "$ubuntuid" \
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