#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Star Wars Battlefront II
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180919.1

# Set game-specific variables

GAME_ID='star-wars-battlefront-2'
GAME_NAME='Star Wars Battlefront II'

ARCHIVE_GOG='setup_sw_battlefront2_2.0.0.5.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/star_wars_battlefront_ii'
ARCHIVE_GOG_MD5='51284c8a8e777868219e811ada284fb1'
ARCHIVE_GOG_VERSION='1.1-gog2.0.0.5'
ARCHIVE_GOG_SIZE='9100000'
ARCHIVE_GOG_TYPE='rar'
ARCHIVE_GOG_GOGID='1421404701'
ARCHIVE_GOG_PART1='setup_sw_battlefront2_2.0.0.5-1.bin'
ARCHIVE_GOG_PART1_MD5='dc36b03c9c43fb8d3cb9b92c947daaa4'
ARCHIVE_GOG_PART1_TYPE='rar'
ARCHIVE_GOG_PART2='setup_sw_battlefront2_2.0.0.5-2.bin'
ARCHIVE_GOG_PART2_MD5='5d4000fd480a80b6e7c7b73c5a745368'
ARCHIVE_GOG_PART2_TYPE='rar'

ARCHIVE_DOC_DATA_PATH='game'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_GAME_BIN_PATH='game/gamedata'
ARCHIVE_GAME_BIN_FILES='*.exe binkw32.dll eax.dll unicows.dll'

ARCHIVE_GAME_MOVIES_PATH='game/gamedata'
ARCHIVE_GAME_MOVIES_FILES='data/_lvl_pc/movies'

ARCHIVE_GAME_DATA_PATH='game/gamedata'
ARCHIVE_GAME_DATA_FILES='data'

DATA_DIRS='./savegames'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='battlefrontii.exe'
APP_MAIN_ICON='battlefrontii.exe'

PACKAGES_LIST='PKG_MOVIES PKG_BIN PKG_DATA'

PKG_MOVIES_ID="${GAME_ID}-movies"
PKG_MOVIES_DESCRIPTION='movies'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_MOVIES_ID $PKG_DATA_ID wine"
PKG_BIN_DEPS_DEB='libtxc-dxtn-s2tc | libtxc-dxtn-s2tc0 | libtxc-dxtn0 | libtxc-dxtn'
PKG_BIN_DEPS_ARCH='lib32-libtxc_dxtn'

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

ln --symbolic "$(readlink --canonicalize "$ARCHIVE_PART1")" "$PLAYIT_WORKDIR/$GAME_ID.r00"
ln --symbolic "$(readlink --canonicalize "$ARCHIVE_PART2")" "$PLAYIT_WORKDIR/$GAME_ID.r01"
extract_data_from "$PLAYIT_WORKDIR/$GAME_ID.r00"
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Estract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
