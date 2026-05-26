#!/usr/bin/env bash

# script-pkgs init-script
slugkde="vinceliuice/Vimix-kde"
slugicon="vinceliuice/Vimix-icon-theme"
sluggtk="vinceliuice/Vimix-gtk-themes"
slugcursor="vinceliuice/Vimix-cursors"
slugs=("$slugkde" "$slugicon" "$sluggtk" "$slugcursor")
tag=""
for slug in "${slugs[@]}"; do
    ghcommits="https://api.github.com/repos/$slug/commits"
    tag="$tag$(curl -sL "$ghcommits" | jq -eMcr 'first | .["sha"]')" || exit 1
done

# script-pkgs install-script
temp="$(mktemp -d)" || exit 1
tempkde="$temp/kde"
tempicon="$temp/icon"
tempgtk="$temp/theme"
tempcursor="$temp/cursor"
git clone "https://github.com/$slugkde" "$tempkde" || exit 1
#mapfile -t files < <(find "$tempkde" -name "*.desktop") || exit 1
#for file in "${files[@]}"; do
#    desktoptojson -i "$file" -o "/dev/stdout" \
#        | jq -MrRs 'split("\n") |
#	    (to_entries | map(select(.["value"] == "{") | .["key"]) | first) as $start |
#            (to_entries | map(select(.["value"] == "}") | .["key"]) | first) as $end |
#            .[($start):($end + 1)] | join("\n") | fromjson |
#            . + {"KPackageStructure": "Plasma/LookAndFeel"}' \
#        | sponge "${file%.desktop}.json" || exit 1
#done
cd "$tempkde" || exit 1
bash "install.sh" || exit 1
git clone "https://github.com/$slugicon" "$tempicon" || exit 1
cd "$tempicon" || exit 1
bash "install.sh" -a || exit 1
git clone "https://github.com/$sluggtk" "$tempgtk" || exit 1
cd "$tempgtk" || exit 1
bash "install.sh" --theme "all" || exit 1
git clone "https://github.com/$slugcursor" "$tempcursor" || exit 1
cd "$tempcursor" || exit 1
bash "install.sh" || exit 1
# shellcheck disable=SC2174
mkdir -p -m 775 "$HOME/.icons" || exit 1
dirs=("Vimix-cursors" "Vimix-white-cursors")
for dir in "${dirs[@]}"; do
    rm -rf "$HOME/.icons/$dir" || exit 1
    mv "$HOME/.local/share/icons/$dir" "$HOME/.icons/$dir" || exit 1
done
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    temp="$(mktemp -d)" || exit 1
    tempkde="$temp/kde"
    tempicon="$temp/icon"
    tempgtk="$temp/theme"
    tempcursor="$temp/theme"
    git clone "https://github.com/$slugkde" "$tempkde" || exit 1
    mapfile -t files < <(find "$tempkde" -name "*.desktop") || exit 1
    for file in "${files[@]}"; do
        desktoptojson -i "$file" -o "/dev/stdout" \
            | jq -Mr '. + {"KPackageStructure": "Plasma/LookAndFeel"}' \
            | sponge "${file%.desktop}.json" || exit 1
    done
    cd "$tempkde" || exit 1
    bash "install.sh" || exit 1
    git clone "https://github.com/$slugicon" "$tempicon" || exit 1
    cd "$tempicon" || exit 1
    bash "install.sh" -a || exit 1
    git clone "https://github.com/$sluggtk" "$tempgtk" || exit 1
    cd "$tempgtk" || exit 1
    bash "install.sh" --theme "all" || exit 1
    git clone "https://github.com/$slugcursor" "$tempcursor" || exit 1
    cd "$tempcursor" || exit 1
    bash "install.sh" || exit 1
    # shellcheck disable=SC2174
    mkdir -p -m 775 "$HOME/.icons" || exit 1
    dirs=("Vimix-cursors" "Vimix-white-cursors")
    for dir in "${dirs[@]}"; do
        rm -rf "$HOME/.icons/$dir" || exit 1
        mv "$HOME/.local/share/icons/$dir" "$HOME/.icons/$dir" || exit 1
    done
    # shellcheck disable=SC2034
    status="updated"
fi
