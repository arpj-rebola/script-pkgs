#!/usr/bin/env bash

# url="https://gitlab.com/api/v4/projects/37107648"
# version="$(curl "$url/repository/tags" \
#     | jq -Mcr 'first | .["name"]' | cut -f2 -d'v')" || exit 1
# temp="$(mktemp)" || exit 1
# url="$url/packages/generic/sddm-eucalyptus-drop/$version/sddm-eucalyptus-drop-v${version}.zip"
# wget -O "$temp" "$url" || exit 1
# sudo sddmthemeinstaller --install "$temp" || exit 1
# exit 0