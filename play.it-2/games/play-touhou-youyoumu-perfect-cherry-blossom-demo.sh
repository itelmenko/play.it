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
# Touhou Youyoumu ~ Perfect Cherry Blossom - Demo
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190419.1

# Set game-specific variables

GAME_ID='touhou-youyoumu-perfect-cherry-blossom-demo'
GAME_NAME='Touhou Youyoumu ~ Perfect Cherry Blossom - Demo'

SCRIPT_DEPS='iconv convmv'

ARCHIVE_ZUN='youmu_tr011.lzh'
ARCHIVE_ZUN_URL='http://www16.big.or.jp/~zun/html/th07_update.html'
ARCHIVE_ZUN_MD5='05360e859c1a3ca173b9d57d96a45b9b'
ARCHIVE_ZUN_VERSION='0.11-zun'
ARCHIVE_ZUN_SIZE='11000'
ARCHIVE_ZUN_TYPE='lzh'

ARCHIVE_DOC_DATA_PATH='youmu'
ARCHIVE_DOC_DATA_FILES='*.txt マニュアル'

ARCHIVE_GAME_BIN_PATH='youmu'
ARCHIVE_GAME_BIN_FILES='*.exe'

ARCHIVE_GAME_DATA_PATH='youmu'
ARCHIVE_GAME_DATA_FILES='*.dat'

CONFIG_FILES='th07.cfg'
DATA_DIRS='./userdata'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='th07.exe'
APP_MAIN_ICON='th07.exe'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_TYPE='wine'
APP_CONFIG_PRERUN='export LC_ALL=ja_JP.UTF-8'
APP_CONFIG_EXE='custom.exe'
APP_CONFIG_ICON='custom.exe'
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"
PKG_BIN_DEPS_DEB='fonts-wqy-microhei'
PKG_BIN_DEPS_ARCH='wqy-microhei'
PKG_BIN_DEPS_GENTOO='media-fonts/wqy-microhei'
#shellcheck disable=SC1112
PKG_BIN_POSTINST_WARN='You may need to generate the ja_JP.UTF-8 locale for the configuration program to run
You need a MIDI synthetiser for music to play in the game (you can use timidity++ or fluidsynth if you don’t have a hardware synthetiser)'

# Load common functions

target_version='2.10'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

# Convert the file names to UTF-8 encoding

find "$PLAYIT_WORKDIR/gamedata" -exec convmv --notest -f SHIFT-JIS -t UTF-8 {} + >/dev/null 2>&1

prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Convert the text files to UTF-8 encoding

for file in "${PKG_DATA_PATH}${PATH_DOC}"/*.txt; do
	contents="$(iconv --from-code SHIFT-JIS --to-code UTF-8 "$file")"
	printf '%s' "$contents" > "$file"
done

# Fix website link

pattern='s|http://www16\.big\.or\.jp/.zun/|http://www16.big.or.jp/~zun/|'
file="${PKG_DATA_PATH}${PATH_DOC}/readme.txt"
sed --in-place "$pattern" "$file"

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_CONFIG'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
write_launcher 'APP_MAIN' 'APP_CONFIG'

# Store saved games and settings outside of WINE prefix

# shellcheck disable=SC2016
saves_path='$WINEPREFIX/drive_c/users/$(whoami)/Application Data/ShanghaiAlice/th07tr' #TODO: check this
# shellcheck disable=SC2016
pattern='s#init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"#&'
pattern="$pattern\\nif [ ! -e \"$saves_path\" ]; then"
pattern="$pattern\\n\\tmkdir --parents \"${saves_path%/*}\""
pattern="$pattern\\n\\tln --symbolic \"\$PATH_DATA/userdata\" \"$saves_path\""
pattern="$pattern\\nfi#"
sed --in-place "$pattern" "${PKG_BIN_PATH}${PATH_BIN}"/*

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
