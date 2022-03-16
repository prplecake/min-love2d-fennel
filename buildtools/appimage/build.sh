#!/bin/bash

set -eo >/dev/null

CURRENT_APPIMAGEKIT_RELEASE=9
ARCH="$(uname -m)"

if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <version>"
        exit 0
fi

VERSION="$1"
LOVEFILE="$2"

# eg 
# https://github.com/love2d/love/releases/download/11.4/love-11.4-x86_64.AppImage
# https://github.com/love2d/love/releases/download/11.3/love-11.3-x86_64.AppImage
# https://github.com/love2d/love/releases/download/11.2/love-11.2-x86_64.AppImage
# https://github.com/love2d/love/releases/download/11.1/love-11.1-linux-x86_64.AppImage
LOVE_AppImage_URL=https://github.com/love2d/love/releases/download/${VERSION}/love-${VERSION}-${ARCH}.AppImage
if [ $VERSION == "11.1" ]
then
    LOVE_AppImage_URL=https://github.com/love2d/love/releases/download/${VERSION}/love-${VERSION}-linux-${ARCH}.AppImage
fi
CACHE_DIR=${HOME}/.cache/love-release/love
LOVE_AppImage=$CACHE_DIR/love-${VERSION}-${ARCH}.AppImage

if ! test -d ${CACHE_DIR}; then
    mkdir -p ${CACHE_DIR}
fi

if ! test -f ${LOVE_AppImage}; then
    curl -L -C - -o ${LOVE_AppImage} ${LOVE_AppImage_URL}
    chmod +x ${LOVE_AppImage}
fi

if ! test -f ${LOVE_AppImage}; then
    echo "No tarball found for $VERSION in $LOVE_AppImage"
    exit 1
fi

download_if_needed() {
        if ! test -f "$1"; then
                if ! curl -L -o "$1" "https://github.com/AppImage/AppImageKit/releases/download/${CURRENT_APPIMAGEKIT_RELEASE}/$1"; then
                        echo "Failed to download appimagetool"
                        echo "Please supply it manually"
                        exit 1
                fi
                chmod +x "$1"
        fi
}

main() {
        download_if_needed appimagetool-${ARCH}.AppImage    
        # Extract the tarball build into a folder
        rm -rf love-prepared
        mkdir -p love-prepared
        cd love-prepared
        $LOVE_AppImage --appimage-extract 1> /dev/null
        mv squashfs-root/* .
        rm squashfs-root/.DirIcon
        rmdir squashfs-root
        # Add our small wrapper script (yay, more wrappers), and AppRun
        local desktopfile="love.desktop"
        local icon="love"
        local target="love-${VERSION}"

        if test -f ../../game.desktop.in; then
                desktopfile="game.desktop"
                cp ../../game.desktop.in .
        fi
        if test -f ../../game.svg; then
                icon="game"
                cp ../../game.svg .
        fi
        if test -f ${LOVEFILE}; then
                if [ $VERSION == "11.4" ]
                then
                    dir="bin"
                else
                    dir="usr/bin"
                fi                
                target="game"
                cat $dir/love ${LOVEFILE} > $dir/love-fused
                mv $dir/love-fused $dir/love
                chmod +x $dir/love
    else
                echo "Love file ${LOVEFILE} not found"
        fi

        # Add our desktop file
        mv ${desktopfile} ${desktopfile}.in
        sed -e "s/%ICON%/${icon}/" "${desktopfile}.in" > "$desktopfile"
        rm "${desktopfile}.in"

        # Add a DirIcon
        cp "${icon}.svg" .DirIcon

        # Clean up
        if test -f ../../game.desktop.in; then
                rm love.desktop.in
        fi
        if test -f ../../game.svg; then
                rm love.svg
        fi

        # Now build the final AppImage
        cd ..

        # ./love-prepared/AppRun -n love-prepared "${target}-${ARCH}.AppImage"
        # Work around missing FUSE/docker
        ./appimagetool-${ARCH}.AppImage --appimage-extract 1> /dev/null
        ./squashfs-root/AppRun -n love-prepared "${target}-${ARCH}.AppImage" 1> /dev/null
        rm -rf love-prepared/
}

main "$@"
