#!/usr/bin/env bash

# script-pkgs init-script
slug="vinceliuice/Layan-cursors"
ghcommits="https://api.github.com/repos/$slug/commits"
url="https://github.com/$slug"
tag="$(curl -sL "$ghcommits" | jq -eMcr 'first | .["sha"]')" || exit 1
target="/$HOME/.icons"
src="$HOME/.local/share/icons"
dirs=("Layan-cursors" "Layan-white-cursors" "Layan-border-cursors")

# script-pkgs install-script
if ! test -e "$target"; then
    install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
fi
temp="$(mktemp -d)" || exit 1
git clone "$url" "$temp" || exit 1
cd "$temp" || exit 1
bash "install.sh" || exit 1
for dir in "${dirs[@]}"; do
    rm -rf "${target:?}/$dir" || exit 1
    mv "$src/$dir" "$target/$dir" || exit 1
done
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    temp="$(mktemp -d)" || exit 1
    git clone "$url" "$temp" || exit 1
    cd "$temp" || exit 1
    bash "install.sh" || exit 1
    for dir in "${dirs[@]}"; do
        rm -rf "${target:?}/$dir" || exit 1
        mv "$src/$dir" "$target/$dir" || exit 1
    done
    kcminit mouse || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi
