#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
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
# Baldurʼs Gate - Enhanced Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180930.1

# Set game-specific variables

GAME_ID='baldurs-gate-1-enhanced-edition'
GAME_NAME='Baldurʼs Gate - Enhanced Edition'

ARCHIVE_GOG='baldur_s_gate_enhanced_edition_en_2_5_23121.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/baldurs_gate_enhanced_edition'
ARCHIVE_GOG_MD5='853f6e66db6cc5a4df0f72d23d65fcf7'
ARCHIVE_GOG_SIZE='3300000'
ARCHIVE_GOG_VERSION='2.5.17.0-gog23121'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='baldur_s_gate_enhanced_edition_en_2_3_67_3_20146.sh'
ARCHIVE_GOG_OLD2_MD5='4d08fe21fcdeab51624fa2e0de2f5813'
ARCHIVE_GOG_OLD2_SIZE='3200000'
ARCHIVE_GOG_OLD2_VERSION='2.3.67.3-gog20146'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='gog_baldur_s_gate_enhanced_edition_2.5.0.9.sh'
ARCHIVE_GOG_OLD1_MD5='224be273fd2ec1eb0246f407dda16bc4'
ARCHIVE_GOG_OLD1_SIZE='3200000'
ARCHIVE_GOG_OLD1_VERSION='2.3.67.3-gog2.5.0.9'

ARCHIVE_GOG_OLD0='gog_baldur_s_gate_enhanced_edition_2.5.0.7.sh'
ARCHIVE_GOG_OLD0_MD5='37ece59534ca63a06f4c047d64b82df9'
ARCHIVE_GOG_OLD0_SIZE='3200000'
ARCHIVE_GOG_OLD0_VERSION='2.3.67.3-gog2.5.0.7'

ARCHIVE_OPTIONAL_LIBSSL32='libssl_1.0.0_32-bit.tar.gz'
ARCHIVE_OPTIONAL_LIBSSL32_URL='https://www.dotslashplay.it/ressources/libssl/'
ARCHIVE_OPTIONAL_LIBSSL32_MD5='9443cad4a640b2512920495eaf7582c4'

ARCHIVE_OPTIONAL_ICONS='baldurs-gate-1-enhanced-edition_icons.tar.gz'
ARCHIVE_OPTIONAL_ICONS_URL='https://www.dotslashplay.it/ressources/baldurs-gate-1-enhanced-edition/'
ARCHIVE_OPTIONAL_ICONS_MD5='58401cf80bc9f1a9e9a0896f5d74b02a'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='BaldursGate engine.lua'

ARCHIVE_GAME_L10N_PATH='data/noarch/game'
ARCHIVE_GAME_L10N_FILES='lang'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='movies music chitin.key Manuals scripts data'

ARCHIVE_ICONS_PATH='.'
ARCHIVE_ICONS_FILES='16x16 24x42 32x32 48x48 64x64 256x256'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='libs'
APP_MAIN_EXE='BaldursGate'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_DESCRIPTION='localizations'
# Easier upgrade from packages generated with pre-20180926.3 scripts
PKG_L10N_PROVIDE='baldurs-gate-enhanced-edition-l10n'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20180926.3 scripts
PKG_DATA_PROVIDE='baldurs-gate-enhanced-edition-data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID glibc libstdc++ glx openal libxrandr alsa xcursor"
PKG_BIN_DEPS_ARCH='lib32-openssl-1.0'
# Easier upgrade from packages generated with pre-20180926.3 scripts
PKG_BIN_PROVIDE='baldurs-gate-enhanced-edition'
# Keep compatibility with old archives
PKG_BIN_DEPS_GOG_OLD0="$PKG_L10N_ID $PKG_DATA_ID glibc libstdc++ glx openal libxrandr alsa xcursor json"
PKG_BIN_DEPS_GOG_OLD1="$PKG_BIN_DEPS_GOG_OLD0"
PKG_BIN_DEPS_GOG_OLD2="$PKG_BIN_DEPS_GOG_OLD0"

# Load common functions

target_version='2.10'

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

# Use libSSL 1.0.0 32-bit archive (Debian packages only)

if [ "$OPTION_PACKAGE" = 'deb' ]; then
	ARCHIVE_MAIN="$ARCHIVE"
	set_archive 'ARCHIVE_LIBSSL32' 'ARCHIVE_OPTIONAL_LIBSSL32'
	ARCHIVE="$ARCHIVE_MAIN"
fi

# Try to load icons archive

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_ICONS' 'ARCHIVE_OPTIONAL_ICONS'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Get icons

PKG='PKG_DATA'
if [ "$ARCHIVE_ICONS" ]; then
	(
		ARCHIVE='ARCHIVE_ICONS'
		extract_data_from "$ARCHIVE_ICONS"
	)
	organize_data 'ICONS' "$PATH_ICON_BASE"
else
	icons_get_from_workdir 'APP_MAIN'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Include libSSL 1.0.0 32-bit (Debian packages only)

if [ "$ARCHIVE_LIBSSL32" ]; then
	(
		# shellcheck disable=SC2030
		ARCHIVE='ARCHIVE_LIBSSL32'
		extract_data_from "$ARCHIVE_LIBSSL32"
	)
	mkdir --parents "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	mv "$PLAYIT_WORKDIR/gamedata"/* "${PKG_BIN_PATH}${PATH_GAME}/$APP_MAIN_LIBS"
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

use_archive_specific_value 'PKG_BIN_DEPS'
# shellcheck disable=SC2031
case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0'|'ARCHIVE_GOG_OLD1'|'ARCHIVE_GOG_OLD2')
		case "$OPTION_PACKAGE" in
			('arch')
				cat > "$postinst" <<- EOF
				if [ ! -e /usr/lib32/libjson.so.0 ] && [ -e /usr/lib32/libjson-c.so ] ; then
				    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
				    ln --symbolic /usr/lib32/libjson-c.so "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
				fi
				EOF
			;;
			('deb')
				cat > "$postinst" <<- EOF
				if [ ! -e /lib/i386-linux-gnu/libjson.so.0 ]; then
				    mkdir --parents "$PATH_GAME/$APP_MAIN_LIBS"
				    for file in\
				        libjson-c.so\
				        libjson-c.so.2\
				        libjson-c.so.3
				    do
				        if [ -e "/lib/i386-linux-gnu/\$file" ] ; then
				            ln --symbolic "/lib/i386-linux-gnu/\$file" "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
				            break
				        fi
				    done
				fi
				EOF
			;;
		esac
		cat > "$prerm" <<- EOF
		if [ -e "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0" ]; then
		    rm "$PATH_GAME/$APP_MAIN_LIBS/libjson.so.0"
		fi
		EOF
	;;
esac
write_metadata 'PKG_BIN'
write_metadata 'PKG_L10N' 'PKG_DATA'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
