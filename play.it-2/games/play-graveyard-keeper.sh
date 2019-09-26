#!/bin/sh
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
# Graveyard Keeper
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190926.4

# Set game-specific variables

GAME_ID='graveyard-keeper'
GAME_NAME='Graveyard Keeper'

ARCHIVE_GOG='graveyard_keeper_1_124v2_30010.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/graveyard_keeper'
ARCHIVE_GOG_MD5='7d231af29281dcf9188508487dc2cbf4'
ARCHIVE_GOG_SIZE='920000'
ARCHIVE_GOG_VERSION='1.124.2-gog30010'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='graveyard_keeper_1_123_29391.sh'
ARCHIVE_GOG_OLD1_MD5='409540bb23b6c26ad42fd85d9f5440ec'
ARCHIVE_GOG_OLD1_SIZE='940000'
ARCHIVE_GOG_OLD1_VERSION='1.123-gog29391'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='graveyard_keeper_1_122_25858.sh'
ARCHIVE_GOG_OLD0_MD5='ad75b8ed2c4b74a763849918da672f5b'
ARCHIVE_GOG_OLD0_SIZE='920000'
ARCHIVE_GOG_OLD0_VERSION='1.122-gog25858'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Graveyard?Keeper.x86 Graveyard?Keeper_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Graveyard?Keeper.x86_64 Graveyard?Keeper_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Graveyard?Keeper_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='export TERM="${TERM%-256color}"'
APP_MAIN_EXE_BIN32='Graveyard Keeper.x86'
APP_MAIN_EXE_BIN64='Graveyard Keeper.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Graveyard Keeper_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2 glx libudev1"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
