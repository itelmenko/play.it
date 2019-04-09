#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, BetaRays
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
# Yume Nikki
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190409.1

# Set game-specific variables

GAME_ID='yume-nikki'
GAME_NAME='Yume Nikki'

SCRIPT_DEPS='iconv convmv lzh' # lzh is needed for the inner archive

ARCHIVE_PLAYISM='YumeNikki_EN.zip'
ARCHIVE_PLAYISM_URL='http://playism-games.com/game/20/yume-nikki'
ARCHIVE_PLAYISM_MD5='fd1e659f777ad81bd61ebd6df573140e'
ARCHIVE_PLAYISM_VERSION='0.10a-playism'
ARCHIVE_PLAYISM_SIZE='66000'
ARCHIVE_PLAYISM_TYPE='zip'

ARCHIVE_DOC_DATA_PATH='YumeNikki_EN'
ARCHIVE_DOC_DATA_FILES='./*.txt'

ARCHIVE_GAME_BIN_PATH='.'
ARCHIVE_GAME_BIN_FILES='./RPG_RT.* ./Harmony.dll'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='./CharSet ./Panorama ./Picture ./BattleWeapon ./Movie ./ChipSet ./System2 ./Sound ./FaceSet ./System ./Title ./Monster ./Battle2 ./Backdrop ./BattleCharSet ./GameOver ./Music ./Frame ./Battle ./Map*.lmu'

APP_MAIN_TYPE='wine'
APP_MAIN_PRERUN='export LC_ALL=ja_JP.UTF-8'
APP_MAIN_EXE='RPG_RT.exe'
APP_MAIN_ICON='RPG_RT.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"
PKG_BIN_DEPS_DEB='fonts-wqy-microhei'
PKG_BIN_DEPS_ARCH='wqy-microhei'
PKG_BIN_DEPS_GENTOO='media-fonts/wqy-microhei'
PKG_BIN_POSTINST_WARN='You may need to generate the ja_JP.UTF-8 locale to play this game'

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

# Convert the text files to UTF-8 encoding

for file in "$PLAYIT_WORKDIR/gamedata/$ARCHIVE_DOC_DATA_PATH"/*.txt
do
	contents="$(iconv --from-code SHIFT-JIS "$file")"
	printf '%s' "$contents" > "$file"
done
sed -i 's/¥/\\/g' "$PLAYIT_WORKDIR/gamedata/$ARCHIVE_DOC_DATA_PATH/YumeNikkiREADME.txt" # Fix windows paths

(
        ARCHIVE='INNER_ARCHIVE'
        INNER_ARCHIVE="$PLAYIT_WORKDIR/gamedata/YumeNikki_EN/YumeNikki.lzh"
        INNER_ARCHIVE_TYPE='lzh'
        extract_data_from "$INNER_ARCHIVE"
        rm "$INNER_ARCHIVE"
)

# Convert the file names to UTF-8 encoding

find "$PLAYIT_WORKDIR/gamedata" -exec convmv --notest -f SHIFT-JIS -t UTF-8 {} + >/dev/null 2>/dev/null

prepare_package_layout

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN'

# Build package

write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
