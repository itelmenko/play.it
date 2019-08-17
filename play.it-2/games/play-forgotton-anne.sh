#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2019, Mopi
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
# Forgotton Anne
# build native packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20190727.3

# Set game-specific variables

GAME_ID='forgotton-anne'
GAME_NAME='Forgotton Anne'

ARCHIVE_GOG='setup_forgotton_anne_5.5.3_(29552).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/forgotton_anne'
ARCHIVE_GOG_MD5='2f6b17e78651f6ccc9070705b879a6ae'
ARCHIVE_GOG_VERSION='5.5.3-gog29552'
ARCHIVE_GOG_SIZE='9500000'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_PART1='setup_forgotton_anne_5.5.3_(29552)-1.bin'
ARCHIVE_GOG_PART1_MD5='8f6e836ff3519e4759af8c51ed89655d'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_forgotton_anne_5.5.3_(29552)-2.bin'
ARCHIVE_GOG_PART2_MD5='728970d510b82fc1d9d336c9e26fb8c3'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='forgottonanne.exe unityplayer.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='app forgottonanne_data'

APP_WINETRICKS='dxvk'
APP_MAIN_PRERUN='pulseaudio --start'
APP_MAIN_TYPE='wine'
APP_MAIN_EXE='forgottonanne.exe'
APP_MAIN_ICON='forgottonanne.exe'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks glx pulseaudio"
PKG_BIN_DEPS_ARCH='lib32-vulkan-icd-loader'
PKG_BIN_DEPS_DEB='' #TODO
PKG_BIN_DEPS_GENTOO='' #TODO

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
# shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package
PKG='PKG_DATA'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
