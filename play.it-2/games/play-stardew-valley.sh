#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2019, Solène "Mopi" Huault
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
# Stardew Valley
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20191009.1

# Set game-specific variables

GAME_ID='stardew-valley'
GAME_NAME='Stardew Valley'

ARCHIVE_GOG='stardew_valley_1_3_36_27827.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/stardew_valley'
ARCHIVE_GOG_MD5='8dd18eb151471a5901592188dfecb8a3'
ARCHIVE_GOG_SIZE='990000'
ARCHIVE_GOG_VERSION='1.3.36-gog27827'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='stardew_valley_en_1_3_28_22957.sh'
ARCHIVE_GOG_OLD1_MD5='e1e98cc3e891f5aafc23fb6617d6bc05'
ARCHIVE_GOG_OLD1_SIZE='970000'
ARCHIVE_GOG_OLD1_VERSION='1.3.28-gog22957'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_stardew_valley_2.8.0.10.sh'
ARCHIVE_GOG_OLD0_MD5='27c84537bee1baae4e3c2f034cb0ff2d'
ARCHIVE_GOG_OLD0_SIZE='490000'
ARCHIVE_GOG_OLD0_VERSION='1.2.33-gog2.8.0.10'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='lib mcs.bin.x86 StardewValley.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='lib64 mcs.bin.x86_64 StardewValley.bin.x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Content BmFont.dll Lidgren.Network.dll mono monoconfig MonoGame.Framework.dll MonoGame.Framework.dll.config Mono.Posix.dll Mono.Security.dll mscorlib.dll StardewValley StardewValley.exe mcs GalaxyCSharp.dll GalaxyCSharp.dll.config System.Configuration.dll System.Core.dll System.Data.dll System.dll System.Drawing.dll System.Runtime.Serialization.dll System.Security.dll System.Xml.dll System.Xml.Linq.dll WindowsBase.dll xTile.dll'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='export TERM="${TERM%-256color}"'
APP_MAIN_EXE_BIN32='StardewValley.bin.x86'
APP_MAIN_EXE_BIN64='StardewValley.bin.x86_64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ openal sdl2 glx alsa"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Get game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Make save game manager binaries executable

if [ $DRY_RUN -eq 0 ]; then
	chmod +x "${PKG_BIN32_PATH}${PATH_GAME}/mcs.bin.x86"
	chmod +x "${PKG_BIN64_PATH}${PATH_GAME}/mcs.bin.x86_64"
fi

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
