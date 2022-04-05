#!/bin/bash

set -e

notice() {
  echo -e "\033[36m $1 \033[0m "
}
fail() {
  echo -e "\033[41;37m 失败 \033[0m $1"
}

src_dir=$(pwd)/deepin-calculator # deepin-calculator根目录
build_dir=$src_dir/build      # 构建目录
tmp_dir=$src_dir/temp          # 存放appimagetool
pkg_dir=$src_dir/AppDir        # 存放打包产物
rm -rf "$pkg_dir"

export LD_LIBRARY_PATH=/opt/Qt/5.15.2/gcc_64/lib:$LD_LIBRARY_PATH
#export DESTDIR=$(pkg_dir)

# download project
if [ ! -d "$src_dir" ]; then
  git clone https://hub.fastgit.xyz/linuxdeepin/deepin-calculator.git
fi
cd "$src_dir"

# build project && make install to AppDir
sed -i 's#-fPIE#-L/usr/lib/x86_64-linux-gnu -L/opt/Qt/5.15.2/gcc_64/lib -I/opt/Qt/5.15.2/gcc_64/include -fPIE#' tests/CMakeLists.txt src/CMakeLists.txt
export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig:/opt/Qt/5.15.2/gcc_64/lib/pkgconfig:$PKG_CONFIG_PATH"

#mkdir "$build_dir"
cd "$build_dir"
cmake ..
make -j"$(nproc)"
make install DESTDIR="$pkg_dir"
#cmake -B "$build_dir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
#cmake --build "$build_dir" -j"$(nproc)"
#cmake --build "$build_dir" --target install DESTDIR="$pkg_dir"

#mkdir -p "$(pkg_dir)"/usr/{bin,lib,share/applications,share/icons}
#mkdir -p "$(pkg_dir)"/usr/share/icons/hicolor/scalable/apps

# desktop
cp "$pkg_dir"/usr/local/share/applications/deepin-calculator.desktop "$pkg_dir"
# icon
cp "$pkg_dir"/usr/local/share/icons/hicolor/scalable/apps/deepin-calculator.svg "$pkg_dir"

cat >"$pkg_dir/AppRun" <<-'EOF'
#!/bin/bash
export LD_LIBRARY_PATH="$APPDIR/usr/lib:$LD_LIBRARY_PATH"
if [[ -f ~/debug.sh ]];then
  echo "====DEBUG====="
  ~/debug.sh
fi
export QT_PLUGIN_PATH=$APPDIR/usr/lib/qt5/plugins
exec $APPDIR/usr/local/bin/deepin-calculator -platformtheme deepin -style chameleon
EOF
chmod +x "$pkg_dir/AppRun"

# install libraries needed
install_lib() {
  lib_name=$1
  notice "install lib: $lib_name"
  find=0
  for path in /usr/lib/x86_64-linux-gnu /usr/lib /lib/x86_64-linux-gnu /opt/Qt/5.15.2/gcc_64/lib; do
    if ls "$path/$lib_name"* 1>/dev/null 2>&1; then
      echo "found in $path"
      cp -dr "$path/$lib_name"* "$pkg_dir"/usr/lib
      find=1
    fi
  done
  if [[ find == 0 ]]; then
    fail "库文件不存在 0"
    exit 1
  fi
}

install_libs() {
  for lib in "$@"; do
    install_lib "$lib"
  done
}

mkdir -p "$pkg_dir"/usr/lib/
install_libs libgsettings-qt

#cp -dr /opt/Qt/5.15.2/gcc_64/plugins "$(pkg_dir)"/usr

mkdir -p "$pkg_dir"/usr/lib/qt5/plugins
#cp -dr /opt/Qt/5.15.2/gcc_64/plugins/{iconengines,imageformats,platforms,platformthemes,styles} "$(pkg_dir)"/usr/lib/qt5/plugins
cp -dr /opt/Qt/5.15.2/gcc_64/plugins/* "$pkg_dir"/usr/lib/qt5/plugins
cp -dr /opt/Qt/5.15.2/gcc_64/lib/* "$pkg_dir"/usr/lib
cp -dr /usr/local/lib/libQt5Xdg* "$pkg_dir"/usr/lib
cd "$pkg_dir"/usr/lib && ln -s . x86_64-linux-gnu

if [ ! -d "$tmp_dir" ]; then
    mkdir "$tmp_dir"
fi

# download appimagetool
if [[ $ACTION_MODE == 'true' ]]; then
  appimagetool_host="github.com"
else
  appimagetool_host="download.fastgit.org"
fi
if [ ! -f "$tmp_dir/appimagetool-x86_64.AppImage" ]; then
  wget "https://$appimagetool_host/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" \
    -O "$tmp_dir/appimagetool-x86_64.AppImage"
fi
chmod a+x "$tmp_dir/appimagetool-x86_64.AppImage"

# make appimage
notice "MAKE APPIMAGE"
export ARCH=x86_64
"$tmp_dir"/appimagetool-x86_64.AppImage --version
"$tmp_dir"/appimagetool-x86_64.AppImage "$pkg_dir" "$build_dir/deepin-calculator.AppImage"
chmod +x "$build_dir/deepin-calculator.AppImage"