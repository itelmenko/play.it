#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2019, BetaRays
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# This software is provided by the copyright holders and contributors "as is"
# and any express or implied warranties, including, but not limited to, the
# implied warranties of merchantability and fitness for a particular purpose
# are disclaimed. In no event shall the copyright holder or contributors be
# liable for any direct, indirect, incidental, special, exemplary, or
# consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether in
# contract, strict liability, or tort (including negligence or otherwise)
# arising in any way out of the use of this software, even if advised of the
# possibility of such damage.
###

###
# CrossCode - Demo
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190614.1

# Set game-specific variables

GAME_ID='crosscode-demo'
GAME_NAME='CrossCode - Demo'

ARCHIVES_LIST='ARCHIVE_CROSSCODE'

ARCHIVE_CROSSCODE='crosscode-demo.zip'
ARCHIVE_CROSSCODE_URL='https://www.cross-code.com/en/home'
ARCHIVE_CROSSCODE_MD5='22c54c8c415ecf056bd703dbed09c13d'
ARCHIVE_CROSSCODE_VERSION='0.7.1beta-crosscode'
ARCHIVE_CROSSCODE_SIZE='130000'
ARCHIVE_CROSSCODE_TYPE='zip'

ARCHIVE_OPTIONAL_NWJS_32='nwjs-v0.39.0-linux-ia32.tar.gz'
ARCHIVE_OPTIONAL_NWJS_32_URL='https://nwjs.io/downloads/'
ARCHIVE_OPTIONAL_NWJS_32_MD5='cba7aed7d2307e835a625ced8713e6d3'

ARCHIVE_OPTIONAL_NWJS_64='nwjs-v0.39.0-linux-x64.tar.gz'
ARCHIVE_OPTIONAL_NWJS_64_URL='https://nwjs.io/downloads/'
ARCHIVE_OPTIONAL_NWJS_64_MD5='88d51da8f6ac54c0f3d7c213ee629fd2'

ARCHIVE_DOC_WINE_PATH='.'
ARCHIVE_DOC_WINE_FILES='credits.html'

ARCHIVE_GAME_WINE_PATH='.'
ARCHIVE_GAME_WINE_FILES='crosscode-demo.exe nw.pak ffmpegsumo.dll icudt.dll'

ARCHIVE_DOC_MAIN_32_PATH='.'
ARCHIVE_DOC_MAIN_32_FILES='nwjs-v0.39.0-linux-ia32/credits.html'

ARCHIVE_GAME_MAIN_32_PATH='nwjs-v0.39.0-linux-ia32'
ARCHIVE_GAME_MAIN_32_FILES='lib *.bin icudtl.dat resources.pak locales nw'

ARCHIVE_DOC_MAIN_64_PATH='.'
ARCHIVE_DOC_MAIN_64_FILES='nwjs-v0.39.0-linux-x64/credits.html'

ARCHIVE_GAME_MAIN_64_PATH='nwjs-v0.39.0-linux-x64'
ARCHIVE_GAME_MAIN_64_FILES='lib *.bin icudtl.dat resources.pak locales nw'

APP_WINE_TYPE='wine'
APP_WINE_EXE='crosscode-demo.exe'
APP_WINE_ICON='favicon.png'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='nw'
APP_MAIN_ICON='favicon.png'

PACKAGES_LIST='PKG_WINE'

# glx is here because it seems nw can use regular OpenGL when swiftshader isn't present

PKG_WINE_ID="${GAME_ID}-wine"
PKG_WINE_ARCH='32'
PKG_WINE_PROVIDE="${GAME_ID}"
PKG_WINE_DEPS='wine glx alsa'

PKG_MAIN_32_ARCH='32'
PKG_MAIN_32_DEPS='glx nss alsa glibc gtk2 xcursor libxrandr'
PKG_MAIN_32_DEPS_DEB='' #TODO: fill
PKG_MAIN_32_DEPS_ARCH='' #TODO: fill
PKG_MAIN_32_DEPS_GENTOO='dapp-accessibility/at-spi2-core dev-libs/atk dev-libs/expat dev-libs/glib:2 dev-libs/nspr net-print/cups sys-apps/dbus sys-apps/util-linux x11-libs/cairo x11-libs/gdk-pixbuf x11-libs/libX11 x11-libs/libxcb x11-libs/libXcomposite x11-libs/libXdamage x11-libs/libXext x11-libs/libXfixes x11-libs/libXi x11-libs/libXrender x11-libs/libXScrnSaver x11-libs/libXtst x11-libs/pango'

PKG_MAIN_64_ARCH='64'
PKG_MAIN_64_DEPS='glx glibc nss alsa gtk2 xcursor libxrandr'
PKG_MAIN_64_DEPS_DEB='' #TODO: fill
PKG_MAIN_64_DEPS_ARCH='' #TODO: fill
PKG_MAIN_64_DEPS_GENTOO='dev-libs/glib:2 dev-libs/nspr app-accessibility/at-spi2-core dev-libs/atk dev-libs/expat net-print/cups sys-apps/dbus sys-apps/util-linux x11-libs/cairo x11-libs/gdk-pixbuf x11-libs/libX11 x11-libs/libxcb x11-libs/libXcomposite x11-libs/libXdamage x11-libs/libXext x11-libs/libXfixes x11-libs/libXi x11-libs/libXrender x11-libs/libXScrnSaver x11-libs/libXtst x11-libs/pango'

# Load common functions

target_version='2.11'

if [ -z "$PLAYIT_LIB2" ]; then
	: "${XDG_DATA_HOME:="$HOME/.local/share"}"
	for path in\
		"$PWD"\
		"$XDG_DATA_HOME/play.it"\
		'/usr/local/share/games/play.it'\
		'/usr/local/share/play.it'\
		'/usr/share/games/play.it'\
		'/usr/share/play.it'
	do
		if [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
fi
if [ -z "$PLAYIT_LIB2" ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'libplayit2.sh not found.\n'
	exit 1
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Use optional nw.js native executables

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_NWJS_32' 'ARCHIVE_OPTIONAL_NWJS_32'
if [ "$ARCHIVE_NWJS_32" ]; then
	PACKAGES_LIST="$PACKAGES_LIST PKG_MAIN_32"
	SCRIPT_DEPS="$SCRIPT_DEPS unzip"
fi
archive_set 'ARCHIVE_NWJS_64' 'ARCHIVE_OPTIONAL_NWJS_64'
if [ "$ARCHIVE_NWJS_64" ]; then
	PACKAGES_LIST="$PACKAGES_LIST PKG_MAIN_64"
	SCRIPT_DEPS="$SCRIPT_DEPS unzip"
fi
ARCHIVE="$ARCHIVE_MAIN"
[ "$ARCHIVE_NWJS_32" ] || [ "$ARCHIVE_NWJS_64" ] && {
	select_package_architecture
	# shellcheck disable=SC2086
	set_temp_directories $PACKAGES_LIST
	check_deps
}

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
[ "$ARCHIVE_NWJS_32" ] && (
	ARCHIVE='ARCHIVE_NWJS_32'
	extract_data_from "$ARCHIVE_NWJS_32"
)
[ "$ARCHIVE_NWJS_64" ] && (
	ARCHIVE='ARCHIVE_NWJS_64'
	extract_data_from "$ARCHIVE_NWJS_64"
)
if [ "$ARCHIVE_NWJS_32" ] || [ "$ARCHIVE_NWJS_64" ]; then
	exe_path="$PLAYIT_WORKDIR/gamedata/crosscode-demo.exe"
	dd if="$exe_path" bs="$(unzip -l "$exe_path" 2>&1 1>/dev/null | grep --extended-regexp --only-matching '[0-9]+ extra bytes' | grep --extended-regexp --only-matching '^[0-9]+')" skip=1 of="$PLAYIT_WORKDIR/gamedata/crosscode-demo_exe.zip" status=none
fi
for PKG in $PACKAGES_LIST; do
	if [ "$PKG" = 'PKG_WINE' ]; then
		continue
	fi
	doc_dir="$(get_value "${PKG}_PATH")${PATH_DOC}/crosscode"
	mkdir --parents "$doc_dir"
	cp "$PLAYIT_WORKDIR/gamedata/credits.html" "$doc_dir/"

	cat "$PLAYIT_WORKDIR/gamedata/crosscode-demo_exe.zip" >> "$PLAYIT_WORKDIR/gamedata/$(get_value "ARCHIVE_GAME_${PKG#PKG_}_PATH")/nw"

done
prepare_package_layout

# Extract game icons

extract_data_from "$PLAYIT_WORKDIR/gamedata/crosscode-demo_exe.zip"
for PKG in $PACKAGES_LIST; do
	if [ "$PKG" = 'PKG_WINE' ]; then
		icons_get_from_workdir 'APP_WINE'
		continue
	fi
	icons_get_from_workdir 'APP_MAIN'
done

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in $PACKAGES_LIST; do
	if [ "$PKG" = 'PKG_WINE' ]; then
		launcher_write 'APP_WINE'
		continue
	fi
	launcher_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

#TODO: separate wine with 32bits and 64bits
print_instructions

exit 0
