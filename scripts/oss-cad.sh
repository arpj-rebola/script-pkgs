#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
slug="YosysHQ/oss-cad-suite-build"
releases="https://api.github.com/repos/$slug/releases"
tag="$(curl -sL "$releases" | jq -Mcr \
    'map(select(.["prerelease"] | not)) | first | .["tag_name"]')" || exit 1
target="/opt/oss-cad"
links=("mcy" "boolector" "avy" "aigbmc" "eqy" "nextpnr" "verilator" "iverilog")
cdlinks=("tabbypy3" "yosys" "sby" "sby-gui" "yosys-abc")

# script-pkgs install-script
url="$(curl -sL "$releases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
    .["assets"] | .[] | select(.["name"] | test("^oss-cad-suite-linux-x64-.*\\.tgz$")) |
    .["browser_download_url"]')" || exit 1
tgz="$(mktemp)" || exit 1
wget -O "$tgz" "$url" || exit 1
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
tar -xzf "$tgz" --strip-components=1 -C "$target" || exit 1
for link in "${links[@]}"; do
    sudo rm -f "/usr/bin/$link" || exit 1
    sudo ln -s "$target/bin/$link" "/usr/bin/$link" || exit 1
done
for link in "${cdlinks[@]}"; do
    sudo rm -f "/usr/bin/$link" || exit 1
    sudo install -m 755 -o root -g root /dev/null "/usr/bin/$link" || exit 1
    cat << EOF | sudo tee -a "/usr/bin/$link" > "/dev/null" || exit 1
#!/usr/bin/env bash
PATH="$target/bin:\$PATH"
$link "\$@"
EOF
done
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    url="$(curl -sL "$releases" | jq -eMcr --arg tag "$tag" '.[] | select(.["tag_name"] == $tag) |
        .["assets"] | .[] | select(.["name"] | test("^oss-cad-suite-linux-x64-.*\\.tgz$")) |
        .["browser_download_url"]')" || exit 1
    tgz="$(mktemp)" || exit 1
    wget -O "$tgz" "$url" || exit 1
    sudo rm -rf "$target" || exit 1
    sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
    tar -xzf "$tgz" --strip-components=1 -C "$target" || exit 1
    for link in "${links[@]}"; do
        sudo rm -f "/usr/bin/$link" || exit 1
        sudo ln -s "$target/bin/$link" "/usr/bin/$link" || exit 1
    done
    for link in "${cdlinks[@]}"; do
        sudo rm -f "/usr/bin/$link" || exit 1
        sudo install -m 755 -o root -g root /dev/null "/usr/bin/$link" || exit 1
        cat << EOF | sudo tee -a "/usr/bin/$link" > "/dev/null" || exit 1
#!/usr/bin/env bash
PATH="$target/bin:\$PATH"
$link "\$@"
EOF
    done
    # shellcheck disable=SC2034
    status="updated"
fi