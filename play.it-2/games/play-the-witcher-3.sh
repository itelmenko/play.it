#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2019, Mopi
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
# The Witcher 3: Wild Hunt
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20191212.2

# Set game-specific variables

GAME_ID='the-witcher-3'
GAME_NAME='The Witcher 3: Wild Hunt'

ARCHIVE_GOG='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/the_witcher_3_wild_hunt_game_of_the_year_edition'
ARCHIVE_GOG_MD5='321ed8cc0faedb903190a708686a1b50'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_VERSION='1.31a-gog9709'
ARCHIVE_GOG_SIZE='38000000'
ARCHIVE_GOG_PART1='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-1.bin'
ARCHIVE_GOG_PART1_MD5='8aab6124c22f1360585ee2285ea6d8f7'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-2.bin'
ARCHIVE_GOG_PART2_MD5='3966e84f941b9fba384eb4a2b0b23c65'
ARCHIVE_GOG_PART2_TYPE='innosetup'
ARCHIVE_GOG_PART3='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-3.bin'
ARCHIVE_GOG_PART3_MD5='bc80aa6b1538ecf757e7db6f3723e056'
ARCHIVE_GOG_PART3_TYPE='innosetup'
ARCHIVE_GOG_PART4='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-4.bin'
ARCHIVE_GOG_PART4_MD5='71660541a0c358ef40802ba62a2c3c09'
ARCHIVE_GOG_PART4_TYPE='innosetup'
ARCHIVE_GOG_PART5='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-5.bin'
ARCHIVE_GOG_PART5_MD5='9ad56c2efc7b09f480f7f8c7922c8b3f'
ARCHIVE_GOG_PART5_TYPE='innosetup'
ARCHIVE_GOG_PART6='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-6.bin'
ARCHIVE_GOG_PART6_MD5='bd3699654b2e34668445219f2bbbc793'
ARCHIVE_GOG_PART6_TYPE='innosetup'
ARCHIVE_GOG_PART7='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-7.bin'
ARCHIVE_GOG_PART7_MD5='1beb5a622e6695d0dd65cac5fab08793'
ARCHIVE_GOG_PART7_TYPE='innosetup'
ARCHIVE_GOG_PART8='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-8.bin'
ARCHIVE_GOG_PART8_MD5='121adc43111562e354d9841800d0c613'
ARCHIVE_GOG_PART8_TYPE='innosetup'
ARCHIVE_GOG_PART9='setup_the_witcher_3_wild_hunt_goty_1.31_(a)_(9709)-9.bin'
ARCHIVE_GOG_PART9_MD5='0f5329306515d6f41a1b4a7b2d38ad74'
ARCHIVE_GOG_PART9_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='bin'

ARCHIVE_GAME_MOVIES_PATH='app'
ARCHIVE_GAME_MOVIES_FILES='content/*/bundles/movies.bundle'

ARCHIVE_GAME_CONTENT1_PATH='app'
ARCHIVE_GAME_CONTENT1_FILES='content/content0'

ARCHIVE_GAME_CONTENT2_PATH='app'
ARCHIVE_GAME_CONTENT2_FILES='content/content1 content/content2 content/content3'

ARCHIVE_GAME_CONTENT3_PATH='app'
ARCHIVE_GAME_CONTENT3_FILES='content/content4'

ARCHIVE_GAME_CONTENT4_PATH='app'
ARCHIVE_GAME_CONTENT4_FILES='content/content5'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='content/content6 content/content7 content/content8 content/content9 metadata.store'

ARCHIVE_GAME_DLC1_PATH='app'
ARCHIVE_GAME_DLC1_FILES='dlc/bob'

ARCHIVE_GAME_DLC2_PATH='app'
ARCHIVE_GAME_DLC2_FILES='dlc/dlc* dlc/ep1'

APP_WINETRICKS='dxvk'

APP_MAIN_TYPE='wine'
APP_MAIN_PRERUN='# run the game binary from its container directory
cd "${APP_EXE%/*}"
APP_EXE="${APP_EXE##*/}"
# store savegames outside of wineprefix
user_data_path="$WINEPREFIX/drive_c/users/$(whoami)/My Documents/The Witcher 3"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "${user_data_path%/*}"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
APP_MAIN_EXE='bin/x64/witcher3.exe'
APP_MAIN_ICON='bin/x64/witcher3.exe'

PACKAGES_LIST='PKG_MOVIES PKG_CONTENT1 PKG_CONTENT2 PKG_CONTENT3 PKG_CONTENT4 PKG_DLC1 PKG_DLC2 PKG_DATA PKG_BIN'

PKG_MOVIES_ID="${GAME_ID}-movies"
PKG_MOVIES_DESCRIPTION='movies'

PKG_CONTENT1_ID="${GAME_ID}-content1"
PKG_CONTENT1_DESCRIPTION='Content, part1'

PKG_CONTENT2_ID="${GAME_ID}-content2"
PKG_CONTENT2_DESCRIPTION='Content, part 2'

PKG_CONTENT3_ID="${GAME_ID}-content3"
PKG_CONTENT3_DESCRIPTION='Content, part 3'

PKG_CONTENT4_ID="${GAME_ID}-content4"
PKG_CONTENT4_DESCRIPTION='Content, part 4'

PKG_DLC1_ID="${GAME_ID}-dlc1"
PKG_DLC1_DESCRIPTION='DLC, part 1'

PKG_DLC2_ID="${GAME_ID}-dlc2"
PKG_DLC2_DESCRIPTION='DLC, part 2'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DEPS="$PKG_MOVIES"

PKG_BIN_ID="$GAME_ID"
PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_CONTENT1_ID $PKG_CONTENT2_ID $PKG_CONTENT3_ID $PKG_CONTENT4_ID $PKG_DLC1 $PKG_DLC2 $PKG_DATA_ID wine"
PKG_BIN_DEPS_ARCH='winetricks'
PKG_BIN_DEPS_DEB='dxvk'
PKG_BIN_DEPS_GENTOO='winetricks'

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

# Use repositories-provided dxvk on Debian

case "$OPTION_PACKAGE" in
	('deb')
		unset APP_WINETRICKS
		APP_MAIN_PRERUN="$APP_MAIN_PRERUN"'
if [ ! -e dxvk_installed ]; then
	sleep 3s
	dxvk-setup install --development
	touch dxvk_installed
fi'
	;;
esac

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icon

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

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
