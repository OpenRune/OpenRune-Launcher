#!/bin/bash

set -e

name="$1"
nameLowercase="$2"

APPBASE="build/macos-x64/"$name".app"

build() {
    echo Launcher sha256sum
    shasum -a 256 build/libs/"$name".jar

    pushd native
    cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 -B build-x64 .
    cmake --build build-x64 --config Release
    popd

    source .jdk-versions.sh

    rm -rf build/macos-x64
    mkdir -p build/macos-x64

    if ! [ -f mac64_jre.tar.gz ] ; then
        curl -Lo mac64_jre.tar.gz $MAC_AMD64_LINK
    fi

    echo "$MAC_AMD64_CHKSUM  mac64_jre.tar.gz" | shasum -c

    mkdir -p $APPBASE/Contents/{MacOS,Resources}

    cp native/build-x64/src/"$name" $APPBASE/Contents/MacOS/
    cp build/libs/"$name".jar $APPBASE/Contents/Resources/
    cp build/packr/macos-x64-config.json $APPBASE/Contents/Resources/config.json
    cp build/filtered-resources/Info.plist $APPBASE/Contents/
    cp osx/runelite.icns $APPBASE/Contents/Resources/icons.icns

    tar zxf mac64_jre.tar.gz
    mkdir $APPBASE/Contents/Resources/jre
    mv jdk-$MAC_AMD64_VERSION-jre/Contents/Home/* $APPBASE/Contents/Resources/jre

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
    # note we use Adam-/create-dmg as upstream does not support UDBZ
    create-dmg --format UDBZ $APPBASE . || true
    mv "$name"\ *.dmg "$name"-x64.dmg

    # dump for CI
    hdiutil imageinfo "$name"-x64.dmg

    if ! hdiutil imageinfo "$name"-x64.dmg | grep -q "Format: UDBZ" ; then
        echo "Format of resulting dmg was not UDBZ, make sure your create-dmg has support for --format"
        exit 1
    fi

    if ! hdiutil imageinfo "$name"-x64.dmg | grep -q "Apple_HFS" ; then
        echo Filesystem of dmg is not Apple_HFS
        exit 1
    fi

    # Notarize app
    if xcrun notarytool submit "$name"-x64.dmg --wait --keychain-profile "AC_PASSWORD" ; then
        xcrun stapler staple "$name"-x64.dmg
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