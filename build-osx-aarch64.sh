#!/bin/bash

set -e

name="$1"
nameLowercase="$2"

APPBASE="build/macos-aarch64/"$name".app"

build() {
    echo Launcher sha256sum
    shasum -a 256 build/libs/"$name".jar

    pushd native
    cmake -DCMAKE_OSX_ARCHITECTURES=arm64 -B build-aarch64 .
    cmake --build build-aarch64 --config Release
    popd

    source .jdk-versions.sh

    rm -rf build/macos-aarch64
    mkdir -p build/macos-aarch64

    if ! [ -f mac_aarch64_jre.tar.gz ] ; then
        curl -Lo mac_aarch64_jre.tar.gz $MAC_AARCH64_LINK
    fi

    echo "$MAC_AARCH64_CHKSUM  mac_aarch64_jre.tar.gz" | shasum -c

    mkdir -p $APPBASE/Contents/{MacOS,Resources}

    cp native/build-aarch64/src/"$name" $APPBASE/Contents/MacOS/
    cp build/libs/"$name".jar $APPBASE/Contents/Resources/
    cp build/packr/macos-aarch64-config.json $APPBASE/Contents/Resources/config.json
    cp build/filtered-resources/Info.plist $APPBASE/Contents/
    cp osx/runelite.icns $APPBASE/Contents/Resources/icons.icns

    tar zxf mac_aarch64_jre.tar.gz
    mkdir $APPBASE/Contents/Resources/jre
    mv jdk-$MAC_AARCH64_VERSION-jre/Contents/Home/* $APPBASE/Contents/Resources/jre

    echo Setting world execute permissions on "$name"
    pushd $APPBASE
    chmod g+x,o+x Contents/MacOS/"$name"
    popd

    otool -l $APPBASE/Contents/MacOS/"$name"
}

dmg() {
    SIGNING_IDENTITY="Developer ID Application"
    codesign -f -s "${SIGNING_IDENTITY}" --entitlements osx/signing.entitlements --options runtime $APPBASE || true

    # create-dmg exits with an error code due to no code signing, but is still okay
    create-dmg $APPBASE . || true
    mv "$name"\ *.dmg "$name"-aarch64.dmg

    # dump for CI
    hdiutil imageinfo "$name"-aarch64.dmg

    if ! hdiutil imageinfo "$name"-aarch64.dmg | grep -q "Format: ULFO" ; then
        echo Format of dmg is not ULFO
        exit 1
    fi

    if ! hdiutil imageinfo "$name"-aarch64.dmg | grep -q "Apple_HFS" ; then
        echo Filesystem of dmg is not Apple_HFS
        exit 1
    fi

    # Notarize app
    if xcrun notarytool submit "$name"-aarch64.dmg --wait --keychain-profile "AC_PASSWORD" ; then
        xcrun stapler staple "$name"-aarch64.dmg
    fi
}

build_flag=0
dmg_flag=0
extra_args=()

# Skip first two args (name, nameLowercase), start parsing from $3
shift 2

while test $# -gt 0; do
  case "$1" in
    --build)
      build_flag=1
      shift
      ;;
    --dmg)
      dmg_flag=1
      shift
      ;;
    *)
      extra_args+=("$1")
      shift
      ;;
  esac
done

# Optionally: print or use extra_args if needed
# echo "Extra arguments: ${extra_args[@]}"

if [ $build_flag -eq 1 ]; then
  build
fi

if [ $dmg_flag -eq 1 ]; then
  dmg
fi