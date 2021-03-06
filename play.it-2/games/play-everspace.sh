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
# Everspace
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190806.2

# Set game-specific variables

GAME_ID='everspace'
GAME_NAME='Everspace'

ARCHIVE_GOG='everspace_1_3_4_29339.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/everspace'
ARCHIVE_GOG_TYPE='mojosetup_unzip'
ARCHIVE_GOG_MD5='2010b839534fb5a265eea6116b9193ae'
ARCHIVE_GOG_VERSION='1.3.4-gog29339'
ARCHIVE_GOG_SIZE='11000000'

ARCHIVE_GOG_OLD1='everspace_1_3_3_25886.sh'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'
ARCHIVE_GOG_OLD1_MD5='df8f210059a515ef738f247bfcd61bb2'
ARCHIVE_GOG_OLD1_VERSION='1.3.3-gog25886'
ARCHIVE_GOG_OLD1_SIZE='11000000'

ARCHIVE_GOG_OLD0='everspace_en_1_3_2_3_22978.sh'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'
ARCHIVE_GOG_OLD0_MD5='4290b47c1396f140198f45a74bf53abf'
ARCHIVE_GOG_OLD0_VERSION='1.3.2.3-gog22978'
ARCHIVE_GOG_OLD0_SIZE='11000000'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Engine RSG/Binaries RSG/Plugins'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='RSG/Content'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='RSG/Binaries/Linux/RSG-Linux-Shipping'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ openal"

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

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
