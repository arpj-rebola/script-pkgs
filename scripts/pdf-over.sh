#!/usr/bin/env bash

# script-pkgs init-script
target="/opt/pdf-over"
slug="a-sit/PDF-Over"
repo="https://github.com/$slug"
ghtags="https://api.github.com/repos/$slug/tags"
release="$(curl -sL "$ghtags" | jq -Mcr 'first')" || exit 1
tag="$(jq -Mcrn --argjson release "$release" \
    '$release | .["commit"] | .["sha"]')" || exit 1

# script-pkgs install-script
version="$(jq -Mcrn --argjson release "$release" \
    '$release | .["name"] | ltrimstr("pdf-over-")')" || exit 1
temp="$(mktemp -d)" || exit 1
javahome="$(update-java-alternatives -l | jq -McrRs 'split("\n") |
    map(capture("^java-1\\.17[^\\s]*\\s+[0-9A-F]+\\s+(?<path>.*)$")) |
    first | .["path"]')" || exit 1
javabin="$javahome/bin/java"
installer="$temp/pdf-over-build/pdf-over_linux-x86_64.jar"
git clone "$repo" "$temp" || exit 1
git -C "$temp" checkout "$tag" || exit 1
JAVA_HOME="$javahome" mvn -B install -Plinux -Dno-native-profile \
    -f "$temp/pom.xml" || exit 1
sudo rm -rf "$target" || exit 1
sudo install -o "$USER" -g "$USER" -m 755 -d "$target" || exit 1
"$javabin" -DINSTALL_PATH="$target" -jar "$installer" -options-system -language eng || exit 1
echo -n "[Desktop Entry]
Categories=
Comment=PDF-Over $version
Comment[en]=PDF-Over $version
Encoding=UTF-8
Exec=$target/pdf-over_linux.sh
GenericName=
GenericName[en]=
Icon=$target/icons/icon.png
MimeType=
Name=PDF-Over
Name[en]=PDF-Over
Path=$target
ServiceTypes=
SwallowExec=
SwallowTitle=
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=root" \
    | sponge "$HOME/.local/share/applications/PDF-Over.desktop" || exit 1
status="installed"

# script-pkgs update-script
# shellcheck disable=SC2154
if test "$tag" != "$prev"; then
    version="$(jq -Mcrn --argjson release "$release" \
        '$release | .["name"] | ltrimstr("pdf-over-")')" || exit 1
    temp="$(mktemp -d)" || exit 1
    javahome="$(update-java-alternatives -l | jq -McrRs 'split("\n") |
        map(capture("^java-1\\.17[^\\s]*\\s+[0-9A-F]+\\s+(?<path>.*)$")) |
        first | .["path"]')" || exit 1
    javabin="$javahome/bin/java"
    installer="$temp/pdf-over-build/pdf-over_linux-x86_64.jar"
    git clone "$repo" "$temp" || exit 1
    git -C "$temp" checkout "$tag" || exit 1
    JAVA_HOME="$javahome" mvn -B install -Plinux -Dno-native-profile \
        -f "$temp/pom.xml" || exit 1
    sudo rm -rf "$target" || exit 1
    sudo install -o "$USER" -g "$USER" -m 755 -d "$target" || exit 1
    "$javabin" -DINSTALL_PATH="$target" -jar "$installer" -options-system -language eng || exit 1
    echo -n "[Desktop Entry]
    Categories=
    Comment=PDF-Over $version
    Comment[en]=PDF-Over $version
    Encoding=UTF-8
    Exec=$target/pdf-over_linux.sh
    GenericName=
    GenericName[en]=
    Icon=$target/icons/icon.png
    MimeType=
    Name=PDF-Over
    Name[en]=PDF-Over
    Path=$target
    ServiceTypes=
    SwallowExec=
    SwallowTitle=
    Terminal=false
    TerminalOptions=
    Type=Application
    X-KDE-SubstituteUID=false
    X-KDE-Username=root" \
        | sponge "$HOME/.local/share/applications/PDF-Over.desktop" || exit 1
    # shellcheck disable=SC2034
    status="updated"
fi
