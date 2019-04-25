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
# VVVVVV
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190425.1

# Set game-specific variables

GAME_ID='vvvvvv'
GAME_NAME='VVVVVV'

ARCHIVE_GOG='gog_vvvvvv_2.0.0.2.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/vvvvvv'
ARCHIVE_GOG_MD5='f25b5dd11ea1778d17d4b2e0b54c7eed'
ARCHIVE_GOG_VERSION='1.0-gog2002'
ARCHIVE_GOG_SIZE='74000'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='./*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game/x86'
ARCHIVE_GAME_BIN32_FILES='vvvvvv.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game/x86_64'
ARCHIVE_GAME_BIN64_FILES='vvvvvv.x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='data.zip VVVVVV.png'

CONFIG_FILES='./play.it_xdg-data-home/VVVVVV/saves/unlock.vvv'
DATA_FILES='./play.it_xdg-data-home/VVVVVV/saves/tsave.vvv ./play.it_xdg-data-home/VVVVVV/saves/qsave.vvv'
DATA_DIRS='./play.it_xdg-data-home/VVVVVV/levels'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='XDG_DATA_HOME="$PATH_PREFIX/play.it_xdg-data-home"
export XDG_DATA_HOME
[ -d "$XDG_DATA_HOME" ] || mkdir "$XDG_DATA_HOME"'
APP_MAIN_EXE_BIN32='vvvvvv.x86'
APP_MAIN_EXE_BIN64='vvvvvv.x86_64'
APP_MAIN_ICON='VVVVVV.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ sdl2 sdl2_mixer"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.11'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launcher_write 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
