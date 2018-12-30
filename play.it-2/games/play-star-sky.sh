#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, BetaRays
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
# Star Sky
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181223.1

# Set game-specific variables

GAME_ID='star-sky'
GAME_NAME='Star Sky'

ARCHIVE_PLAYISM='StarSkyEnglishUbuntu64x_20151013.zip'
ARCHIVE_PLAYISM_URL='https://playism.com/product/blue-moon'
ARCHIVE_PLAYISM_MD5='47fdbddbaa55f2f44e6413340a9ae5a6'
ARCHIVE_PLAYISM_VERSION='20151013-playism'
ARCHIVE_PLAYISM_SIZE='110000'
ARCHIVE_PLAYISM_TYPE='zip'

ARCHIVE_GAME_BIN_PATH='linux64'
ARCHIVE_GAME_BIN_FILES='./starsky ./libffmpegsumo.so'

ARCHIVE_GAME_DATA_PATH='linux64'
ARCHIVE_GAME_DATA_FILES='./icudtl.dat ./nw.pak ./package.nw'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='libs'
APP_MAIN_EXE_BIN='starsky'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc nss gconf freetype xcursor alsa libxrandr libudev1 gtk2 libstdc++"
PKG_BIN_DEPS_DEB='' #TODO
PKG_BIN_DEPS_ARCH='glib2 nspr fontconfig pango cairo libx11 libxi libxext libxfixes libxrender libxcomposite libxdamage libxtst expat libcap dbus gdk-pixbuf2 libnotify'
PKG_BIN_DEPS_GENTOO='dev-libs/glib dev-libs/nspr media-libs/fontconfig x11-libs/pango x11-libs/cairo x11-libs/libX11 x11-libs/libXi x11-libs/libXext x11-libs/libXfixes x11-libs/libXrender x11-libs/libXcomposite x11-libs/libXdamage x11-libs/libXtst dev-libs/expat sys-libs/libcap sys-apps/dbus x11-libs/gdk-pixbuf x11-libs/libnotify'

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	for path in\
		'./'\
		"$XDG_DATA_HOME/play.it/"\
		"$XDG_DATA_HOME/play.it/play.it-2/lib/"\
		'/usr/local/share/games/play.it/'\
		'/usr/local/share/play.it/'\
		'/usr/share/games/play.it/'\
		'/usr/share/play.it/'
	do
		if [ -z "$PLAYIT_LIB2" ] && [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
	if [ -z "$PLAYIT_LIB2" ]; then
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

case "$OPTION_PACKAGE" in
	('arch')
		cat > "$postinst" <<- EOF
		if [ ! -e /usr/lib/libudev.so.0 ]; then
		    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
		    for file in\
		        libudev.so\
		        libudev.so.1
		    do
		        if [ -e "/usr/lib/\$file" ]; then
		            ln --symbolic "/usr/lib/\$file" "$PATH_GAME/$APP_MAIN_LIBS/libudev.so.0"
		            break
		        fi
		    done
		fi
		EOF
	;;
	('deb')
		#TODO
	;;
	('gentoo')
		cat > "$postinst" <<- EOF
		if [ ! -e "/usr/\$(portageq envvar LIBDIR_amd64)/libudev.so.0" ] && [ -e "/usr/\$(portageq envvar LIBDIR_amd64)/libudev.so" ]; then
		    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
		    ln --symbolic "/usr/\$(portageq envvar LIBDIR_amd64)/libudev.so" "$PATH_GAME/$APP_MAIN_LIBS/libudev.so.0"
		fi
		EOF
	;;
esac
cat > "$prerm" <<- EOF
if [ -e "$PATH_GAME/$APP_MAIN_LIBS/libudev.so.0" ]; then
    rm "$PATH_GAME/$APP_MAIN_LIBS/libudev.so.0"
fi
EOF
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
