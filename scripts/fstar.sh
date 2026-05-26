#!/usr/bin/env bash
# shellcheck disable=SC2317

# script-pkgs init-script
tag="$(opam info fstar --raw \
    | jq -McrRs 'split("\n") | .[] | capture("^version: \"(?<tag>.*)\"$") | .["tag"]')" || exit 1

# script-pkgs install-script
opam pin -y add fstar --dev-repo || exit 1
exe="$(which fstar)" || exit 1
dir="$(dirname "$exe")" || exit 1
if test "$exe" != "$dir/fstar"; then
    mv "$exe" "$dir/fstar" || exit 1
fi
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    opam upgrade -y fstar || exit 1
    exe="$(which fstar)" || exit 1
    dir="$(dirname "$exe")" || exit 1
    if test "$exe" != "$dir/fstar"; then
        mv "$exe" "$dir/fstar" || exit 1
    fi
    # shellcheck disable=SC2034
    status="updated"
fi