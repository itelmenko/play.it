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
# Mirrorʼs Edge
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180224.1

# Set game-specific variables

GAME_ID='mirrors-edge'
GAME_NAME='Mirrorʼs Edge'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='setup_mirrors_edge_2.0.0.3.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/mirrors_edge'
ARCHIVE_GOG_MD5='89381d67169f5c6f8f300e172a64f99c'
ARCHIVE_GOG_SIZE='7700000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.3'
ARCHIVE_GOG_TYPE='rar'
ARCHIVE_GOG_PART1='setup_mirrors_edge_2.0.0.3-1.bin'
ARCHIVE_GOG_PART1_MD5='406b99108e1edd17fc60435d1f2c27f9'
ARCHIVE_GOG_PART1_TYPE='rar'
ARCHIVE_GOG_PART2='setup_mirrors_edge_2.0.0.3-2.bin'
ARCHIVE_GOG_PART2_MD5='18f2bd62201904c8e98a4b805a90ab2d'
ARCHIVE_GOG_PART2_TYPE='rar'

ARCHIVE_GAME_BIN_PATH='game'
ARCHIVE_GAME_BIN_FILES='./binaries ./engine'

ARCHIVE_GAME_DATA_PATH='game'
ARCHIVE_GAME_DATA_FILES='./language_setup.ini ./me_icon.ico ./tdgame'

CONFIG_DIRS='./tdgame/config'
DATA_DIRS='./tdgame/savefiles'

APP_WINETRICKS='physx'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='binaries/mirrorsedge.exe'
APP_MAIN_ICON='me_icon.ico'
APP_MAIN_ICON_RES='16 32 48 64 256'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks"

# Load common functions

target_version='2.5'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh"
	elif [ -e './libplayit2.sh' ]; then
		PLAYIT_LIB2='./libplayit2.sh'
	else
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		exit 1
	fi
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Check that all parts of the installer are present

ARCHIVE_MAIN="$ARCHIVE"
set_archive 'ARCHIVE_PART1' 'ARCHIVE_GOG_PART1'
[ "$ARCHIVE_PART1" ] || set_archive_error_not_found 'ARCHIVE_GOG_PART1'
set_archive 'ARCHIVE_PART2' 'ARCHIVE_GOG_PART2'
[ "$ARCHIVE_PART2" ] || set_archive_error_not_found 'ARCHIVE_GOG_PART2'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

ln --symbolic "$(readlink --canonicalize "$ARCHIVE_PART1")" "$PLAYIT_WORKDIR/$GAME_ID.r00"
ln --symbolic "$(readlink --canonicalize "$ARCHIVE_PART2")" "$PLAYIT_WORKDIR/$GAME_ID.r01"
extract_data_from "$PLAYIT_WORKDIR/$GAME_ID.r00"
tolower "$PLAYIT_WORKDIR/gamedata"

for PKG in $PACKAGES_LIST; do
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

PKG='PKG_DATA'
extract_and_sort_icons_from 'APP_MAIN'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
