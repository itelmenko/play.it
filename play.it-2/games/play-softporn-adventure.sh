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
# Softporn Adventure
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180307.1

# Set game-specific variables

GAME_ID='softporn-adventure'
GAME_NAME='Softporn Adventure'

ARCHIVES_LIST='ARCHIVE_GOG'

ARCHIVE_GOG='gog_softporn_adventure_2.0.0.1.sh'
ARCHIVE_GOG_MD5='1e51094f928757140c5a0dacc70773c0'
ARCHIVE_GOG_SIZE='11000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.1'

ARCHIVE_DOC_PATH='data/noarch/docs'
ARCHIVE_DOC_FILES='./*.doc ./*.txt'

ARCHIVE_GAME_PATH='data/noarch/data'
ARCHIVE_GAME_FILES='./*'

DATA_FILES='./*.GAM'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='softporn.exe'
APP_MAIN_ICON='data/noarch/support/icon.png'
APP_MAIN_ICON_RES='256'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ARCH='32'
PKG_MAIN_DEPS_DEB='dosbox'
PKG_MAIN_DEPS_ARCH='dosbox'

# Load common functions

target_version='2.4'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
tolower "$PLAYIT_WORKDIR/gamedata"

organize_data 'DOC'  "$PATH_DOC"
organize_data 'GAME' "$PATH_GAME"
get_icon_from_temp_dir 'APP_MAIN'

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

write_launcher 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
