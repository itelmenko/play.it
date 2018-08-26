#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, Dominique Derrier
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
# SimCity 2000 | 1993
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180826.0

# Set game-specific variables

GAME_ID='sim-city-2000'
GAME_NAME='Sim City 2000'

ARCHIVE_LTF='setup-00014-sim_city_2000_cd-pcdos.exe'
ARCHIVE_LTF_TYPE='innosetup'
ARCHIVE_LTF_URL='https://www.abandonware-france.org/ltf_abandon/ltf_jeu.php?id=14'
ARCHIVE_LTF_MD5='2af6656aac55cd1e2bbada4681c80414'
ARCHIVE_LTF_SIZE='340000'
ARCHIVE_LTF_VERSION='1.0-ltf00014'

ARCHIVE_GAME_BIN_PATH='app/c/sc2000'
ARCHIVE_GAME_BIN_FILES='./*exe ./*cfg ./*mxs ./*bat ./*com ./*txt'

ARCHIVE_GAME_DATA_PATH='app/c/sc2000'
ARCHIVE_GAME_DATA_FILES='./cities ./scenario ./scurkart ./sound ./*bnk ./*cim ./*urk ./*dat'

#DATA_DIRS='./dunecd'
# GAME_IMAGE='' |no cd

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='sc2000.exe'
APP_MAIN_ICON='app/sc2000.ico'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID dosbox"

# Load common functions

target_version='2.10'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icons

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
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
