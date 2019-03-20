#!/bin/sh -e
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
# Narbacular Drop
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190422.3

# Set game-specific variables

GAME_ID='narbacular-drop'
GAME_NAME='Narbacular Drop'

ARCHIVE_NUCLEARMONKEY='narbacular_drop.exe'
ARCHIVE_NUCLEARMONKEY_URL='http://www.nuclearmonkeysoftware.com/downloads.html'
ARCHIVE_NUCLEARMONKEY_MD5='4eca84ea7c520f0f0ca2012ba024efd1'
ARCHIVE_NUCLEARMONKEY_VERSION='1.4-nuclearmonkey'
ARCHIVE_NUCLEARMONKEY_SIZE='40000'
ARCHIVE_NUCLEARMONKEY_TYPE='innosetup'

ARCHIVE_DIGIPEN='NarbacularDropSetup.exe'
ARCHIVE_DIGIPEN_URL='https://www.digipen.edu/showcase/student-games/narbacular-drop'
ARCHIVE_DIGIPEN_MD5='f335eaf8f667e0584ec84af6b9104252'
ARCHIVE_DIGIPEN_VERSION='1.4-digipen'
ARCHIVE_DIGIPEN_SIZE='40000'
ARCHIVE_DIGIPEN_TYPE='innosetup'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.txt *.pdf *.url'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.exe *.dll'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='file.ore' #TODO: check if it is needed

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='narbacular drop.exe'
APP_MAIN_ICON='narbacular drop.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine glx libxrandr"
PKG_BIN_DEPS_ARCH='lib32-alsa-lib'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
