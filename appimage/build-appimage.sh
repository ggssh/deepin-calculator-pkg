#!/bin/bash

# install dependencies
apt install -y libdframeworkdbus-dev libfuse-dev

# build and install to appdir
BUILD_DIR=$(pwd)/build
if [ ! -d "$BUILD_DIR" ]; then
  mkdir "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"/AppDir
export DESTDIR=$BUILD_DIR/AppDir
#sed -i 's#-fPIE#-L/usr/lib/x86_64-linux-gnu -L/opt/Qt/5.15.2/gcc_64/lib -fPIE -fno-sized-deallocation#' $(pwd)/src/CMakeLists.txt


cat $(pwd)/src/CMakeLists.txt
cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "$BUILD_DIR" -j$(nproc)
cmake --build "$BUILD_DIR" --target install

#IMAGE_TOOL=$(pwd )/tools/linuxdeploy-x86_64.AppImage
#if [ ! -f "$IMAGE_TOOL" ]; then
#  wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage -O "$IMAGE_TOOL"
#fi
export APPIMAGE_EXTRACT_AND_RUN=1
#chmod a+x "$IMAGE_TOOL"
chmod a+x $(pwd )/tools/linuxdeploy*
$(pwd )/tools/linuxdeploy-x86_64.AppImage --appdir "$BUILD_DIR"/AppDir
#"$IMAGE_TOOL" --appdir "$BUILD_DIR"/AppDir --plugin qt --output appimge
# copy resources
#cp /opt/Qt/5.15.2/gcc_64/plugins/platforms/* "$BUILD_DIR"/AppDir/usr/lib
#cp "$BUILD_DIR"/AppDir/usr/local/share/applications/deepin-calculator.desktop "$BUILD_DIR"/AppDir
#cp "$BUILD_DIR"/AppDir/usr/local/share/icons/hicolor/scalable/apps/deepin-calculator.svg "$BUILD_DIR"/AppDir
#cp "$BUILD_DIR"/AppDir/usr/local/bin/deepin-calculator "$BUILD_DIR"/AppDir
#mkdir -p "$BUILD_DIR"/AppDir/usr/lib
#cp /usr/lib/libQt5DBus.so* "$BUILD_DIR"/AppDir/usr/lib
#mv "$BUILD_DIR"/AppDir/deepin-calculator "$BUILD_DIR"/AppDir/AppRun

# download appimagetool
IMAGE_TOOL=$(pwd)/tools/appimagetool.AppImage
if [ ! -f "$IMAGE_TOOL" ]; then
  wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O "$IMAGE_TOOL"
fi
chmod a+x "$IMAGE_TOOL"

echo "start packing"
#$IMAGE_TOOL "$BUILD_DIR"/AppDir deepin-calculator.AppImage

# https://github.com/AppImage/AppImageKit/wiki/FUSE  在docker上会出现
$IMAGE_TOOL "$BUILD_DIR"/AppDir deepin-calculator.AppImage