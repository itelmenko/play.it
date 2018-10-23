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
# Faster Than Light
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181023.3

# Set game-specific variables

GAME_ID='faster-than-light'
GAME_NAME='Faster Than Light'

ARCHIVE_GOG='ftl_advanced_edition_1_6_8_24110.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/faster_than_light'
ARCHIVE_GOG_MD5='4d654aeca32de557c109fa5c642ff455'
ARCHIVE_GOG_SIZE='230000'
ARCHIVE_GOG_VERSION='1.6.8-gog24110'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='ftl_advanced_edition_1_6_7_24012.sh'
ARCHIVE_GOG_OLD3_MD5='43392da0d11548b1c16f1263fc5fad65'
ARCHIVE_GOG_OLD3_SIZE='230000'
ARCHIVE_GOG_OLD3_VERSION='1.6.8-gog24012'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='ftl_advanced_edition_en_1_6_7_18662.sh'
ARCHIVE_GOG_OLD2_MD5='2c5254547639b7718dac7a06dabd1d82'
ARCHIVE_GOG_OLD2_SIZE='210000'
ARCHIVE_GOG_OLD2_VERSION='1.6.7-gog18662'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='ftl_advanced_edition_en_1_6_3_17917.sh'
ARCHIVE_GOG_OLD1_MD5='b64692d5302a1ab60d912c5eb5fbc5e4'
ARCHIVE_GOG_OLD1_SIZE='210000'
ARCHIVE_GOG_OLD1_VERSION='1.6.3-gog17917'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_ftl_advanced_edition_2.0.0.2.sh'
ARCHIVE_GOG_OLD0_MD5='2c24b70b31316acefedc082e9441a69a'
ARCHIVE_GOG_OLD0_SIZE='220000'
ARCHIVE_GOG_OLD0_VERSION='1.5.13-gog2.0.0.2'

ARCHIVE_HUMBLE='FTL.1.5.13.tar.gz'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/ftl-faster-than-light'
ARCHIVE_HUMBLE_MD5='791e0bc8de73fcdcd5f461a4548ea2d8'
ARCHIVE_HUMBLE_SIZE='220000'
ARCHIVE_HUMBLE_VERSION='1.5.13-humble140602'

ARCHIVE_DOC0_DATA_PATH_GOG='data/noarch/docs'
ARCHIVE_DOC0_DATA_PATH_HUMBLE='FTL'
ARCHIVE_DOC0_DATA_FILES='*.html *.txt'

ARCHIVE_DOC1_DATA_PATH_GOG='data/noarch/game/data'
ARCHIVE_DOC1_DATA_PATH_HUMBLE='FTL/data'
ARCHIVE_DOC1_DATA_FILES='licenses'

ARCHIVE_GAME_BIN32_PATH_GOG='data/noarch/game/data'
ARCHIVE_GAME_BIN32_PATH_HUMBLE='FTL/data'
ARCHIVE_GAME_BIN32_FILES_GOG='FTL.x86'
ARCHIVE_GAME_BIN32_FILES_HUMBLE='x86'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN32_FILES_GOG_OLD0='x86'

ARCHIVE_GAME_BIN64_PATH_GOG='data/noarch/game/data'
ARCHIVE_GAME_BIN64_PATH_HUMBLE='FTL/data'
ARCHIVE_GAME_BIN64_FILES_GOG='FTL.amd64'
ARCHIVE_GAME_BIN64_FILES_HUMBLE='amd64'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN64_FILES_GOG_OLD0='amd64'

ARCHIVE_GAME_DATA_PATH_GOG='data/noarch/game/data'
ARCHIVE_GAME_DATA_PATH_HUMBLE='FTL/data'
ARCHIVE_GAME_DATA_FILES_GOG='exe_icon.bmp ftl.dat'
ARCHIVE_GAME_DATA_FILES_HUMBLE='exe_icon.bmp resources'
# Keep compatibility with old archives
ARCHIVE_GAME_DATA_FILES_GOG_OLD0='exe_icon.bmp resources'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_ICON0='exe_icon.bmp'
APP_MAIN_ICON1='resources/exe_icon.bmp'

APP_MAIN_LIBS_BIN32_HUMBLE='x86/lib'
APP_MAIN_LIBS_BIN64_HUMBLE='amd64/lib'
APP_MAIN_EXE_BIN32_HUMBLE='x86/bin/FTL'
APP_MAIN_EXE_BIN64_HUMBLE='amd64/bin/FTL'
APP_MAIN_ICONS_LIST_HUMBLE='APP_MAIN_ICON0 APP_MAIN_ICON1'

APP_MAIN_EXE_BIN32_GOG='FTL.x86'
APP_MAIN_EXE_BIN64_GOG='FTL.amd64'
APP_MAIN_ICONS_LIST_GOG='APP_MAIN_ICON0'
# Keep compatibility with old archives
APP_MAIN_LIBS_BIN32_GOG_OLD0='x86/lib'
APP_MAIN_LIBS_BIN64_GOG_OLD0='amd64/lib'
APP_MAIN_EXE_BIN32_GOG_OLD0='x86/bin/FTL'
APP_MAIN_EXE_BIN64_GOG_OLD0='amd64/bin/FTL'
APP_MAIN_ICONS_LIST_GOG_OLD0='APP_MAIN_ICON0 APP_MAIN_ICON1'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS_GOG="$PKG_DATA_ID glibc glx alsa"
PKG_BIN32_DEPS_HUMBLE="$PKG_DATA_ID sdl glu"
# Keep compatibility with old archives
PKG_BIN32_DEPS_GOG_OLD0="$PKG_DATA_ID sdl glu"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS_GOG="$PKG_BIN32_DEPS_GOG"
PKG_BIN64_DEPS_HUMBLE="$PKG_BIN32_DEPS_HUMBLE"
# Keep compatibility with old archives
PKG_BIN64_DEPS_GOG_OLD0="$PKG_BIN32_DEPS_GOG_OLD0"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
case "$ARCHIVE" in
	('ARCHIVE_HUMBLE')
		set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_DATA'
use_archive_specific_value 'APP_MAIN_ICONS_LIST'
icons_get_from_package 'APP_MAIN'

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	use_archive_specific_value "APP_MAIN_EXE_${PKG#PKG_}"
	use_archive_specific_value "APP_MAIN_LIBS_${PKG#PKG_}"
	write_launcher 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
