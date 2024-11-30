#!/bin/bash
APP="sc-controller"
DEPCACHE="/tmp"
BUILDCACHE="/tmp"
EXEC="scc"
LIB="lib"

EVDEV_VERSION=0.7.0
[ x"$BUILD_APPDIR" == "x" ] && BUILD_APPDIR=$(pwd)/appimage


function download_dep() {
	NAME=$1
	URL=$2
	if [ -e ../../${NAME}.obstargz ] ; then
		# Special case for OBS
		cp ../../${NAME}.obstargz ${DEPCACHE}/${NAME}.tar.gz
	elif [ -e ${NAME}.tar.gz ] ; then
		cp ${NAME}.tar.gz ${DEPCACHE}/${NAME}.tar.gz
	elif [ -e ${DEPCACHE}/${NAME}.tar.gz ] ; then
		echo "${DEPCACHE}/${NAME}.tar.gz already downloaded"
	else
		wget -c "${URL}" -O ${DEPCACHE}/${NAME}.tar.gz
	fi
}

function build_dep() {
	NAME="$1"
	mkdir -p ${BUILDCACHE}/${NAME}
	pushd ${BUILDCACHE}/${NAME}
	tar --extract --strip-components=1 -f ${DEPCACHE}/${NAME}.tar.gz
	PYTHONPATH=${BUILD_APPDIR}/usr/lib/python3.12/site-packages python \
		setup.py install --optimize=1 \
		--prefix="/usr/" --root="${BUILD_APPDIR}"
	mkdir -p "${BUILD_APPDIR}/usr/lib/python3.12/site-packages/"
	python setup.py install --prefix="/usr/" --root="${BUILD_APPDIR}"
	popd
}

function unpack_dep() {
	NAME="$1"
	pushd ${BUILD_APPDIR}
	tar --extract --exclude="usr/include**" --exclude="usr/lib/pkgconfig**" \
			--exclude="usr/lib/python3.6**" -f ${DEPCACHE}/${NAME}.tar.gz
	popd
}

set -ex		# display commands, terminate after 1st failure

# Download deps
download_dep "python-3.12.3" "https://archive.archlinux.org/packages/p/python/python-3.12.3-1-x86_64.pkg.tar.zst"
download_dep "python-evdev-1.7.1" "https://github.com/gvalkov/python-evdev/archive/v1.7.1.tar.gz"
download_dep "pylibacl-0.7.0" "https://github.com/iustin/pylibacl/releases/download/v0.7.0/pylibacl-0.7.0.tar.gz"
download_dep "python-gobject-3.49.0" "https://archive.archlinux.org/packages/p/python-gobject/python-gobject-3.49.0-1-x86_64.pkg.tar.zst"
download_dep "python-cairo-1.26.0" "https://archive.archlinux.org/packages/p/python-cairo/python-cairo-1.26.0-2-x86_64.pkg.tar.zst"
download_dep "gobject-introspection-runtime-1.82.0" "https://archive.archlinux.org/packages/g/gobject-introspection-runtime/gobject-introspection-runtime-1.82.0-1-x86_64.pkg.tar.zst"
download_dep "libpng-1.6.44" "https://archive.archlinux.org/packages/l/libpng/libpng-1.6.44-1-x86_64.pkg.tar.zst"
download_dep "gdk-pixbuf-2.42.9" "https://archive.archlinux.org/packages/g/gdk-pixbuf2/gdk-pixbuf2-2.42.9-1-x86_64.pkg.tar.zst"
download_dep "libffi-3.4.6" "https://archive.archlinux.org/packages/l/libffi/libffi-3.4.6-1-x86_64.pkg.tar.zst"
download_dep "libcroco-0.6.13" "https://archive.archlinux.org/packages/l/libcroco/libcroco-0.6.13-2-x86_64.pkg.tar.zst"
download_dep "libxml2-2.13.4" "https://archive.archlinux.org/packages/l/libxml2/libxml2-2.13.4-1-x86_64.pkg.tar.zst"
download_dep "librsvg-2.59.2" "https://archive.archlinux.org/packages/l/librsvg/librsvg-2%3A2.59.2-1-x86_64.pkg.tar.zst"
download_dep "icu-75.1.1" "https://archive.archlinux.org/packages/i/icu/icu-75.1-1-x86_64.pkg.tar.zst"
download_dep "zlib-1:1.3.1" "https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.3.1-2-x86_64.pkg.tar.zst"

# Prepare & build deps
export PYTHONPATH=${BUILD_APPDIR}/usr/lib/python3.12/site-packages/
mkdir -p "$PYTHONPATH"
if [[ $(grep ID_LIKE /etc/os-release) == *"suse"* ]] ; then
	# Special handling for OBS
	ln -s lib64 ${BUILD_APPDIR}/usr/lib
	export PYTHONPATH="$PYTHONPATH":${BUILD_APPDIR}/usr/lib64/python3.12/site-packages/
	LIB=lib64
fi

build_dep "python-evdev-1.7.1"
build_dep "pylibacl-0.7.0"
unpack_dep "python-3.12.3"
unpack_dep "libpng-1.6.44"
unpack_dep "python-cairo-1.26.0"
unpack_dep "libffi-3.4.6"
unpack_dep "python-gobject-3.49.0"
unpack_dep "gobject-introspection-runtime-1.82.0"
unpack_dep "gdk-pixbuf-2.42.9"
unpack_dep "libcroco-0.6.13"
unpack_dep "libxml2-2.13.4"
unpack_dep "librsvg-2.59.2"
unpack_dep "icu-75.1.1"
unpack_dep "zlib-1:1.3.1"

# Remove uneeded files
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-ani.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-bmp.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-gif.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-icns.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-ico.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-jasper.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-jpeg.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-qtif.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-tga.so"
rm -f "${BUILD_APPDIR}/usr/${LIB}/gdk-pixbuf-2.0/2.42.9/loaders/libpixbufloader-tiff.so"
rm -R "${BUILD_APPDIR}/usr/lib/cmake"
rm -R "${BUILD_APPDIR}/usr/share/doc"
rm -R "${BUILD_APPDIR}/usr/share/gtk-doc"
rm -R "${BUILD_APPDIR}/usr/share/locale"
rm -R "${BUILD_APPDIR}/usr/share/man"
rm -R "${BUILD_APPDIR}/usr/share/thumbnailers"
rm -R "${BUILD_APPDIR}/usr/share/vala"
rm -R "${BUILD_APPDIR}/usr/share/icu"

# Build important part
python setup.py build
python setup.py install --prefix ${BUILD_APPDIR}/usr

# Move udev stuff
mv ${BUILD_APPDIR}/usr/lib/udev/rules.d/69-${APP}.rules ${BUILD_APPDIR}/
rmdir ${BUILD_APPDIR}/usr/lib/udev/rules.d/
rmdir ${BUILD_APPDIR}/usr/lib/udev/
cp "/usr/include/linux/input-event-codes.h" ${BUILD_APPDIR}/usr/${LIB}/python3.12/site-packages/scc/

# Move & patch desktop file
mv ${BUILD_APPDIR}/usr/share/applications/${APP}.desktop ${BUILD_APPDIR}/
sed -i "s/Icon=.*/Icon=${APP}/g" ${BUILD_APPDIR}/${APP}.desktop
sed -i "s/Exec=.*/Exec=.\/usr\/bin\/scc gui/g" ${BUILD_APPDIR}/${APP}.desktop

# Convert icon
convert -background none ${BUILD_APPDIR}/usr/share/pixmaps/${APP}.svg ${BUILD_APPDIR}/${APP}.png

# Copy appdata.xml
mkdir -p ${BUILD_APPDIR}/usr/share/metainfo/
cp scripts/${APP}.appdata.xml ${BUILD_APPDIR}/usr/share/metainfo/${APP}.appdata.xml

# Fix shebangs
for x in "${BUILD_APPDIR}/usr/bin"/sc-controller "${BUILD_APPDIR}/usr/bin"/scc* ; do
	sed -i 's|#!/usr/bin/python3.12|#!/usr/bin/env python|' "$x"
done

# Copy AppRun script
cp scripts/appimage-AppRun.sh ${BUILD_APPDIR}/AppRun
chmod +x ${BUILD_APPDIR}/AppRun

echo "Run appimagetool -n ${BUILD_APPDIR} to finish prepared appimage"
