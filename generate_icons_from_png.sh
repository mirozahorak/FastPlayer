#!/bin/bash

# Generate PNG icons from the provided appicon.png

# Base directory
BASE_DIR="/Volumes/DEVEL/_SWIFT/FastPlayer/FastPlayer"

# Sizes: pixel sizes for each
sizes=(16 32 32 64 128 256 256 512 512 1024)

# Corresponding filenames based on Contents.json
names=("icon_16x16.png" "icon_16x16@2x.png" "icon_32x32.png" "icon_32x32@2x.png" "icon_128x128.png" "icon_128x128@2x.png" "icon_256x256.png" "icon_256x256@2x.png" "icon_512x512.png" "icon_512x512@2x.png")

for i in ${!sizes[@]}; do
  size=${sizes[$i]}
  name=${names[$i]}
  magick "$BASE_DIR/appicon.png" -resize ${size}x${size} "$BASE_DIR/Assets.xcassets/AppIcon.appiconset/$name"
done