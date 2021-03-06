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
# Fallout
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190116.4

# Set game-specific variables

GAME_ID='fallout-1'
GAME_NAME='Fallout'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='setup_fallout_2.1.0.18.exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/fallout'
ARCHIVE_GOG_EN_MD5='47b7b3c059d92c0fd6db5881635277ea'
ARCHIVE_GOG_EN_VERSION='1.2-gog2.1.0.18'
ARCHIVE_GOG_EN_SIZE='600000'
ARCHIVE_GOG_EN_TYPE='innosetup'

ARCHIVE_GOG_FR='setup_fallout_french_2.1.0.18.exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/fallout'
ARCHIVE_GOG_FR_MD5='12ba5bb0489b5bafb777c8d07717b020'
ARCHIVE_GOG_FR_VERSION='1.2-gog2.1.0.18'
ARCHIVE_GOG_FR_SIZE='600000'
ARCHIVE_GOG_FR_TYPE='innosetup'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='readme.txt manual.pdf'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='refcard.pdf readme.rtf f1_res_readme.rtf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='falloutw.exe f1_res.dll f1_res_config.exe'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='fallout.cfg'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='critter.dat master.dat data extras fallout.ico'

CONFIG_FILES='./fallout.cfg'
DATA_DIRS='./data/savegame'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='falloutw.exe'
APP_MAIN_ICON='fallout.ico'

APP_RES_ID="${GAME_ID}_resolution"
APP_RES_TYPE='wine'
APP_RES_EXE='f1_res_config.exe'
APP_RES_ICON='f1_res_config.exe'
APP_RES_NAME="$GAME_NAME - resolution"
APP_RES_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20190116.1 scripts
PKG_DATA_PROVIDE='fallout-data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine"
# Easier upgrade from packages generated with pre-20190116.1 scripts
PKG_BIN_PROVIDE='fallout'

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
# shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

prepare_package_layout

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

PKG='PKG_BIN'
icons_get_from_package 'APP_RES'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_RES'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
