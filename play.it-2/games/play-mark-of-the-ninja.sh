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
# Mark of the Ninja
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20180303.1

# Set game-specific variables

GAME_ID='mark-of-the-ninja'
GAME_NAME='Mark of the Ninja'

ARCHIVES_LIST='ARCHIVE_GOG ARCHIVE_HUMBLE'

ARCHIVE_GOG='gog_mark_of_the_ninja_2.0.0.4.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/mark_of_the_ninja'
ARCHIVE_GOG_MD5='126ded567b38580f574478fd994e3728'
ARCHIVE_GOG_SIZE='2200000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.4'

ARCHIVE_HUMBLE='markoftheninja_linux38_1380755375.zip'
ARCHIVE_HUMBLE_MD5='7871a48068ef43e93916325eedd6913e'
ARCHIVE_HUMBLE_SIZE='2300000'
ARCHIVE_HUMBLE_VERSION='1.0-humble130310'

ARCHIVE_DOC_DATA_PATH_GOG='data/noarch/game/bin'
ARCHIVE_DOC_DATA_PATH_HUMBLE='bin'
ARCHIVE_DOC_DATA_FILES='./motn_readme.txt'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN32_FILES='./bin/*32'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='.'
ARCHIVE_GAME_BIN64_FILES='./bin/*64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game'
ARCHIVE_GAME_DATA_PATH_HUMBLE='.'
ARCHIVE_GAME_DATA_FILES='./data* ./bin/*.xpm'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='bin/ninja-bin32'
APP_MAIN_EXE_BIN64='bin/ninja-bin64'
APP_MAIN_ICONS_LIST='APP_MAIN_ICON'
APP_MAIN_ICON='bin/motn_icon.xpm'
APP_MAIN_ICON_RES='128'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx sdl2"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.5'

if [ -z "$PLAYIT_LIB2" ]; then
	[ -n "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"
	if [ -e "$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh" ]; then
		PLAYIT_LIB2="$XDG_DATA_HOME/play.it/play.it-2/lib/libplayit2.sh"
	elif [ -e './libplayit2.sh' ]; then
		PLAYIT_LIB2='./libplayit2.sh'
	else
		printf '\n\033[1;31mError:\033[0m\n'
		printf 'libplayit2.sh not found.\n'
		return 1
	fi
fi
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"

for PKG in $PACKAGES_LIST; do
	organize_data "DOC_${PKG#PKG_}"  "$PATH_DOC"
	organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
done

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Set working directory to the directory containing the game binary before running it

pattern='s|^cd "$PATH_PREFIX"$|cd "$PATH_PREFIX/${APP_EXE%/*}"|'
pattern="$pattern;s|^\"\./\$APP_EXE\"|\"./\${APP_EXE##*/}\"|"
for file in \
"${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID" \
"${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"; do
	sed --in-place "$pattern" "$file"
done

# Build package

postinst_icons_linking 'APP_MAIN'
pattern='s#\(/[^/]\+\).png#\1.xpm#g'
for file in "$postinst" "$prerm"; do
	sed --in-place "$pattern" "$file"
done
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
printf '32-bit:'
print_instructions 'PKG_DATA' 'PKG_BIN32'
printf '64-bit:'
print_instructions 'PKG_DATA' 'PKG_BIN64'

exit 0