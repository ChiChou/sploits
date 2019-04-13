#!/bin/sh

BIN=./bin
DMG=$BIN/Silverlight.dmg
PKG=$BIN/silverlight.pkg

mkdir -p $BIN

if [ ! -f $DMG ]; then
  curl https://download.microsoft.com/download/0/3/E/03EB1393-4F4E-4191-8364-C641FAB20344/50901.00/Silverlight.dmg -o $DMG
fi

if [ ! -f $PKG ]; then
  VOL=$(hdiutil attach $DMG | grep /Volumes | awk '{ print $3 }')
  cp $VOL/silverlight.pkg $PKG
fi
