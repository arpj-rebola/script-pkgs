#!/usr/bin/env bash

# script-pkgs init-script
slugkde="vinceliuice/Qogir-kde"
slugicon="vinceliuice/Qogir-icon-theme"
slugtheme="vinceliuice/Qogir-theme"
slugs=("$slugkde" "$slugicon" "$slugtheme")
tag=""
for slug in "${slugs[@]}"; do
    ghcommits="https://api.github.com/repos/$slug/commits"
    tag="$tag$(curl -sL "$ghcommits" | jq -eMcr 'first | .["sha"]')" || exit 1
done

# script-pkgs install-script
temp="$(mktemp -d)" || exit 1
tempkde="$temp/kde"
tempicon="$temp/icon"
temptheme="$temp/theme"
git clone "https://github.com/$slugkde" "$tempkde" || exit 1
cd "$tempkde" || exit 1
bash "install.sh" || exit 1
git clone "https://github.com/$slugicon" "$tempicon" || exit 1
cd "$tempicon" || exit 1
bash "install.sh" || exit 1
git clone "https://github.com/$slugtheme" "$temptheme" || exit 1
cd "$temptheme" || exit 1
bash "install.sh" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    temp="$(mktemp -d)" || exit 1
    tempkde="$temp/kde"
    tempicon="$temp/icon"
    temptheme="$temp/theme"
    git clone "https://github.com/$slugkde" "$tempkde" || exit 1
    cd "$tempkde" || exit 1
    bash "install.sh" || exit 1
    git clone "https://github.com/$slugicon" "$tempicon" || exit 1
    cd "$tempicon" || exit 1
    bash "install.sh" || exit 1
    git clone "https://github.com/$slugtheme" "$temptheme" || exit 1
    cd "$temptheme" || exit 1
    bash "install.sh" --theme "all" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi