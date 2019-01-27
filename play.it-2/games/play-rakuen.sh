#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# Rakuen
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180408.3

# Set game-specific variables

GAME_ID='rakuen'
GAME_NAME='Rakuen'

ARCHIVE_HUMBLE='rakuen_linux.tgz'
ARCHIVE_HUMBLE_MD5='cae92b2e92cd4e15796a7faa765d2e64'
ARCHIVE_HUMBLE_VERSION='1.0-humble1'
ARCHIVE_HUMBLE_SIZE='200000'

ARCHIVE_DOC_DATA_PATH='Rakuen'
ARCHIVE_DOC_DATA_FILES='*.pdf'

ARCHIVE_GAME_BIN32_PATH='Rakuen'
ARCHIVE_GAME_BIN32_FILES='./Rakuen.x86 ./lib'

ARCHIVE_GAME_BIN64_PATH='Rakuen'
ARCHIVE_GAME_BIN64_FILES='./Rakuen.amd64 ./lib64'

ARCHIVE_GAME_DATA_PATH='Rakuen'
ARCHIVE_GAME_DATA_FILES='./Audio ./Engine.ini ./Engine.rgssad ./Fonts ./icon.png ./mkxp ./mkxp.conf'

CONFIG_FILES='./Engine.ini ./mkxp.conf'

APP_MAIN_TYPE='native_no-prefix'
APP_MAIN_LIBS_BIN32='./lib'
APP_MAIN_LIBS_BIN64='./lib64'
APP_MAIN_EXE_BIN32='Rakuen.x86'
APP_MAIN_EXE_BIN64='Rakuen.amd64'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON'
APP_MAIN_ICON='icon.png'
APP_MAIN_ICON_RES='32'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc sdl2"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.7'

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
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

postinst_icons_linking 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
