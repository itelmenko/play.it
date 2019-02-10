#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2018-2019, Dominique Derrier
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
# Lemmings | floppy drive version
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190210.1

# Set game-specific variables

GAME_ID='lemmings'
GAME_NAME='Lemmings'

ARCHIVE_LTF='jeu-00005-lemmings-pcdos.7z'
ARCHIVE_LTF_TYPE='7z'
ARCHIVE_LTF_URL='https://www.abandonware-france.org/ltf_abandon/ltf_jeu.php?id=5'
ARCHIVE_LTF_MD5='9fb084f3e8945e3280ed3058b6d4d851'
ARCHIVE_LTF_SIZE='800'
ARCHIVE_LTF_VERSION='1.0-ltf00005'

ARCHIVE_GAME_BIN_PATH='lem'
ARCHIVE_GAME_BIN_FILES='*.bat *.exe'

ARCHIVE_GAME_DATA_PATH='lem'
ARCHIVE_GAME_DATA_FILES='*.dat'

ARCHIVE_DOC0_DATA_PATH='.'
ARCHIVE_DOC0_DATA_FILES='*.txt'

ARCHIVE_DOC1_DATA_PATH='lem'
ARCHIVE_DOC1_DATA_FILES='*.doc'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='lemmings.bat'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID dosbox"

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
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
