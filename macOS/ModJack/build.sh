#!/bin/sh

# build kext
pushd 3rd-party/Unrootless-Kext
xcodebuild
cp -r build/Release/Unrootless.kext /tmp/
popd

# build kernel exploit
pushd libinj
make
popd

pushd kernel
make
popd

echo -e '\033[1;32msudo ./kernel/bin/exp\033[0m'
