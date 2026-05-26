#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
url="https://gitlab.com/MIAOresearch/software/VeriPB"
target="/opt/veripb"

# script-pkgs install-script
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 775 -d "$target" || exit 1
git clone "$url" "$target" || exit 1
cd "$target" || exit 1
pip3 install ./ || exit 1
tag="$(git -C "$target" rev-parse HEAD)" || exit 1
status="installed"

# script-pkgs update-script
git -C "$target" pull || exit 1
tag="$(git -C "$target" rev-parse HEAD)" || exit 1
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    cd "$target" || exit 1
    pip3 install ./ || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi
