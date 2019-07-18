#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2018-2019, VA
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
# Tetrobot and Co.
# build native Linux packages from the original installers
# send your bug reports to dev+playit@indigo.re
###

script_version=20190717.1

# Set game-specific variables

GAME_ID='tetrobot-and-co'
GAME_NAME='Tetrobot and Co.'

ARCHIVE_GOG='gog_tetrobot_and_co_2.1.0.6.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/tetrobot-and-co'
ARCHIVE_GOG_MD5='2ad2969e64e19d5753f8822e407c148c'
ARCHIVE_GOG_SIZE='536285184'
ARCHIVE_GOG_VERSION='2.1.0.6-gog1.2.1'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='./*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Data/Mono/x86 Tetrobot?and?Co.x86'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Data/*.assets Data/Managed Data/Mono/etc Data/Resources Data/level0 Data/level1 Data/level2 Data/level3 Data/level4 Data/level5 Data/level6 Data/mainData'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Tetrobot and Co.x86'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glu glx libstdc++ xcursor"

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in PKG_BIN32; do
        write_launcher 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "${PLAYIT_WORKDIR}"

# Print instructions

print_instructions

exit 0

