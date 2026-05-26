#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
ghuser="https://github.com/enzo1982/"
ghreleases="https://api.github.com/repos/enzo1982/freac/releases"
tag="$(curl -sL "$ghreleases" | jq -Mcr \
    'map(select(.["prerelease"] | not)) | first | .["tag_name"]')" || exit 1
commit="$(curl -sL "$ghreleases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
    .["target_commitish"]')" || exit 1
target="/opt/freac"

# script-pkgs install-script
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 755 -d "$target" || exit 1
git clone "$ghuser/smooth/" "$target/smooth" || exit 1
make -j8 -C "$target/smooth" || exit 1
sudo make -j8 -C "$target/smooth" install || exit 1
git clone "$ghuser/boca/" "$target/boca" || exit 1
make -j8 -C "$target/boca" || exit 1
sudo make -j8 -C "$target/boca" install || exit 
git clone "$ghuser/freac/" "$target/freac" || exit 1
git -C "$target/freac" checkout "$commit" || exit 1
make -j8 -C "$target/freac" || exit
sudo make -j8 -C "$target/freac" install || exit
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    sudo rm -rf "$target" || exit 1
    sudo install -o "$USER" -g "$USER" -m 755 -d "$target" || exit 1
    git -C "$target/smooth" pull || exit 1
    make -j8 -C "$target/smooth" || exit 1
    sudo make -j8 -C "$target/smooth" install || exit 1
    git -C "$target/boca" pull || exit 1
    make -j8 -C "$target/boca" || exit 1
    sudo make -j8 -C "$target/boca" install || exit 
    git -C "$target/freac" pull || exit 1
    git -C "$target/freac" checkout "$commit" || exit 1
    make -j8 -C "$target/freac" || exit
    sudo make -j8 -C "$target/freac" install || exit
    # shellcheck disable=SC2034
    status="updated"
fi
