#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
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
# Star Ruler 2
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190221.1

# Set game-specific variables

GAME_ID='star-ruler-2'
GAME_NAME='Star Ruler 2'

ARCHIVE_GOG='gog_star_ruler_2_2.4.0.6.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/star_ruler_2'
ARCHIVE_GOG_MD5='273659f8d5c1e35ab553c86a35855d79'
ARCHIVE_GOG_SIZE='1100000'
ARCHIVE_GOG_VERSION='2.0.2-gog2.4.0.6'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='bin/lin32/libcurl.so.4 bin/lin32/libGLEW.so.1.13 bin/lin32/StarRuler2.bin'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='bin/lin64/libcurl.so.4 bin/lin64/libGLEW.so.1.13 bin/lin64/StarRuler2.bin'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='credits.txt data licenses.txt locales maps mods scripts sr2.icns sr2.ico'

APP_MAIN_TYPE='native_no-prefix'
APP_MAIN_LIBS_BIN32='bin/lin32'
APP_MAIN_LIBS_BIN64='bin/lin64'
APP_MAIN_EXE_BIN32='bin/lin32/StarRuler2.bin'
APP_MAIN_EXE_BIN64='bin/lin64/StarRuler2.bin'
APP_MAIN_ICON='sr2.ico'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ bzip2 freetype gtk2 glu vorbis openal libcurl"
PKG_BIN32_DEPS_ARCH='lib32-libpng'
PKG_BIN32_DEPS_DEB='libpng16-16'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libpng'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"

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

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launcher_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
