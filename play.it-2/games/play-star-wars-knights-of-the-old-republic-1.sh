#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
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
# STAR WARS™: Knights of the Old Republic
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190221.2

# Set game-specific variables

GAME_ID='star-wars-knights-of-the-old-republic-1'
GAME_NAME='Star Wars: Knights of the Old Republic'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='setup_sw_kotor_2.0.0.3.exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic'
ARCHIVE_GOG_EN_MD5='9962e94dabb07411a066c95efb4b78a4'
ARCHIVE_GOG_EN_VERSION='1.03-gog2003'
ARCHIVE_GOG_EN_SIZE='3800000'
ARCHIVE_GOG_EN_TYPE='rar'
ARCHIVE_GOG_EN_GOGID='1207666283'
ARCHIVE_GOG_EN_PART1='setup_sw_kotor_2.0.0.3.bin'
ARCHIVE_GOG_EN_PART1_MD5='2c2cc27ee410948b417f8fa30d0c9201'
ARCHIVE_GOG_EN_PART1_TYPE='rar'

ARCHIVE_GOG_FR='setup_sw_kotor_french_2.0.0.3.exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/star_wars_knights_of_the_old_republic'
ARCHIVE_GOG_FR_MD5='42b90743d069ca60dfd96f9991a5a37c'
ARCHIVE_GOG_FR_VERSION='1.03-gog2003'
ARCHIVE_GOG_FR_SIZE='3900000'
ARCHIVE_GOG_FR_TYPE='rar'
ARCHIVE_GOG_FR_GOGID='1207666283'
ARCHIVE_GOG_FR_PART1='setup_sw_kotor_french_2.0.0.3.bin'
ARCHIVE_GOG_FR_PART1_MD5='81c2b828d0b2708fae8c7b15248bb22d'
ARCHIVE_GOG_FR_PART1_TYPE='rar'

ARCHIVE_DOC_L10N_PATH='game'
ARCHIVE_DOC_L10N_FILES='docs'

ARCHIVE_DOC_DATA_PATH='game'
ARCHIVE_DOC_DATA_FILES='swkotorv103.txt manual.pdf'

ARCHIVE_GAME_BIN_PATH='game'
ARCHIVE_GAME_BIN_FILES='*.exe binkw32.dll patchw32.dll mss32.dll utils/*.exe utils/*.txt'

ARCHIVE_GAME_L10N_PATH='game'
ARCHIVE_GAME_L10N_FILES='patch.erf utils/*.ini utils/swupdateskins lips streamwaves streamsounds dialog.tlk movies/01a.bik movies/02.bik movies/09.bik movies/31a.bik movies/50.bik movies/56b.bik movies/leclogo.bik movies/legal.bik movies/01a.bik movies/02.bik movies/09.bik movies/31a.bik movies/50.bik movies/56b.bik movies/leclogo.bik movies/legal.bik'

ARCHIVE_GAME0_DATA_PATH='game'
ARCHIVE_GAME0_DATA_FILES='chitin.key data miles modules rims streammusic texturepacks movies'

ARCHIVE_GAME1_DATA_PATH='support/app'
ARCHIVE_GAME1_DATA_FILES='swkotor.ini'

DATA_DIRS='./saves ./override'
CONFIG_FILES='./swkotor.ini'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='swkotor.exe'
APP_MAIN_ICON='swkotor.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_EXE='swconfig.exe'
APP_CONFIG_ICON='swconfig.exe'
APP_CONFIG_NAME="${GAME_NAME} - Configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with 20190122.6 scripts
PKG_DATA_PROVIDE='star-wars-knights-of-the-old-republic-data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine glx libxrandr"
# Easier upgrade from packages generated with 20190122.6 scripts
PKG_BIN_PROVIDE='star-wars-knights-of-the-old-republic'

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

extract_data_from "$SOURCE_ARCHIVE_PART1"
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_CONFIG'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
