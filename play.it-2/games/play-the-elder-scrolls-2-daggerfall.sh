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
# The Elder Scrolls II: Daggerfall
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190302.2

# Set game-specific variables

GAME_ID='the-elder-scrolls-2-daggerfall'
GAME_NAME='The Elder Scrolls II: Daggerfall'

ARCHIVE_GOG='setup_tes_daggerfall_2.0.0.4.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_elder_scrolls_iii_morrowind_goty_edition'
ARCHIVE_GOG_MD5='68f1eb4f257d8da4c4eab2104770c49b'
ARCHIVE_GOG_SIZE='580000'
ARCHIVE_GOG_VERSION='1.07.213-gog2.0.0.4'

ARCHIVE_DOC0_DATA_PATH='app'
ARCHIVE_DOC0_DATA_FILES='*.pdf'

ARCHIVE_DOC1_DATA_PATH='tmp'
ARCHIVE_DOC1_DATA_FILES='gog_eula.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.cfg *.exe data/*.exe *.txt *.ini'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='arena2 dagger.ico data *.bnk *.386 *.scr test*'

CONFIG_FILES='./*.cfg'
DATA_DIRS='./pics ./save0 ./save1 ./save2 ./save3 ./save4 ./save5'
DATA_FILES='./arena2/copyfile.dat ./arena2/mapsave.sav ./arena2/*.DAT arena2/*.AMF'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='fall.exe'
APP_MAIN_OPTIONS='z.cfg'
APP_MAIN_ICON='dagger.ico'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
# Easier upgrade from packages generated with pre-20190302.1 script
PKG_DATA_PROVIDE='daggerfall-data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID dosbox"
# Easier upgrade from packages generated with pre-20190302.1 scripts
PKG_BIN_PROVIDE='daggerfall'

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

# Extract icons

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
