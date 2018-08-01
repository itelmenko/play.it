#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2018, Phil Morrell
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
# Age of Empires II
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180728.1

# Set game-specific variables

SCRIPT_DEPS='cabextract'

GAME_ID='age-of-empires-2'
GAME_NAME='Age of Empires II'

ARCHIVE_COLLECTORS='collectors.iso'
ARCHIVE_COLLECTORS_URL='https://www.amazon.co.uk/dp/B00243EZLG'
ARCHIVE_COLLECTORS_MD5='d2ffc3b760064cadf7500d39067f665f'
ARCHIVE_COLLECTORS_VERSION='2.2'
ARCHIVE_COLLECTORS_SIZE='5400000'
ARCHIVE_COLLECTORS_TYPE='mojosetup'

ARCHIVE_FORGOTTEN='fe_update.zip'
ARCHIVE_FORGOTTEN_URL='https://www.forgottenempires.net/install'
ARCHIVE_FORGOTTEN_MD5='5e0225dbdc0d8d2279a88c24626c3956'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='./manual/manual_aoe2*'
ARCHIVE_DOC1_DATA_PATH='aoe2/uk'
ARCHIVE_DOC1_DATA_FILES='./*.rtf ./docs'
ARCHIVE_DOC2_DATA_PATH='aoe2conq/uk'
ARCHIVE_DOC2_DATA_FILES='./*.rtf ./docs'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='./age2_x1/*.exe ./games/forgotten\\ empires/data/language_x1_p1.dll'
ARCHIVE_GAME1_BIN_PATH='aoe2/uk/game'
ARCHIVE_GAME1_BIN_FILES='./*.exe ./*.icd ./*.dll'
ARCHIVE_GAME2_BIN_PATH='aoe2conq/uk/game'
ARCHIVE_GAME2_BIN_FILES='./*.dll ./age2_x1/*.exe ./age2_x1/*.dll ./age2_x1/*.icd'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='./campaign ./data ./games ./history ./random ./savegame ./sound ./taunt ./version.txt'
ARCHIVE_GAME1_DATA_PATH='aoe2/uk/game'
ARCHIVE_GAME1_DATA_FILES='./avi ./campaign ./data ./sound'
ARCHIVE_GAME2_DATA_PATH='aoe2conq/uk/game'
ARCHIVE_GAME2_DATA_FILES='./avi ./campaign ./data ./sound'

APP_WINETRICKS='directplay'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='empires2.exe'
APP_MAIN_ICON='empires2.exe'
APP_MAIN_NAME="$GAME_NAME: The Age of Kings"

APP_CONQUERORS_ID="${GAME_ID}_conquerors"
APP_CONQUERORS_TYPE='wine'
APP_CONQUERORS_EXE='age2_x1/age2_x1.exe'
APP_CONQUERORS_ICON='age2_x1/age2_x1.exe'
APP_CONQUERORS_NAME="$GAME_NAME: The Conquerors"

APP_FORGOTTEN_ID="${GAME_ID}_forgotten"
APP_FORGOTTEN_TYPE='wine'
APP_FORGOTTEN_EXE='age2_x1/age2_x2.exe'
APP_FORGOTTEN_ICON='age2_x1/age2_x2.exe'
APP_FORGOTTEN_NAME="$GAME_NAME: Forgotten Empires"

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine winetricks"

# Load common functions

target_version='2.9'

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

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_FE' 'ARCHIVE_FORGOTTEN'
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

use() {
	rm --recursive "$PLAYIT_WORKDIR/gamedata" || true
	extract_data_from "$1"
	tolower "$PLAYIT_WORKDIR/gamedata"
	prepare_package_layout
}

use "$SOURCE_ARCHIVE"
mv "$PLAYIT_WORKDIR/gamedata/aoe2/uk/game/empires2.cab" "$PLAYIT_WORKDIR"
mv "$PLAYIT_WORKDIR/gamedata/aoe2conq/uk/msgame.cab" "$PLAYIT_WORKDIR"
ARCHIVE_COLLECTORS_TYPE='cabinet'
use "$PLAYIT_WORKDIR/empires2.cab"
use "$PLAYIT_WORKDIR/msgame.cab"
(
	ARCHIVE='ARCHIVE_FE'
	use "$ARCHIVE_FE"
)

# Get icons

icons_get_from_package 'APP_MAIN' 'APP_CONQUERORS' 'APP_FORGOTTEN'

# Write launchers

write_launcher 'APP_MAIN' 'APP_CONQUERORS' 'APP_FORGOTTEN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
