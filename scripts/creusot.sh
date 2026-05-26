#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
slug="creusot-rs/creusot"
ghcommits="https://api.github.com/repos/$slug/commits"
url="https://github.com/$slug"
tag="$(curl -sL "$ghcommits" | jq -eMcr 'first | .["sha"]')" || exit 1
target="/opt/creusot"

# script-pkgs install-script
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
git clone "$url" "$target" || exit 1
cd "$target" || exit 1
OPAMCONFIRMLEVEL="unsafe-yes" bash INSTALL || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    git -C "$target" pull || exit 1
    cd "$target" || exit 1
    OPAMCONFIRMLEVEL="unsafe-yes" bash INSTALL || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi