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
# Warhammer 40,000: Gladius - Relics of War
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190719.3

# Set game-specific variables

GAME_ID='warhammer-40k-gladius-relics-of-war'
GAME_NAME='Warhammer 40,000: Gladius - Relics of War'

ARCHIVE_GOG='warhammer_40_000_gladius_relics_of_war_1_03_00_31042.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/warhammer_40000_gladius_relics_of_war'
ARCHIVE_GOG_MD5='c169fb5b60a2bf04a0e0ae625d53239b'
ARCHIVE_GOG_SIZE='2000000'
ARCHIVE_GOG_VERSION='1.3.0-gog31042'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Binaries/Linux-x86_64/Gladius.bin Binaries/Linux-x86_64/libjpeg.so.8 Binaries/Linux-x86_64/libsteam_api.so Binaries/Linux-x86_64/libboost_system.so.1.65.1'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='*.doc *.pdf Data Documents Manuals Resources'

APP_MAIN_TYPE='native_no-prefix'
APP_MAIN_EXE='Binaries/Linux-x86_64/Gladius.bin'
APP_MAIN_ICON='Data/Video/Textures/Icon.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ freetype openal vorbis libcurl"
PKG_BIN_DEPS_ARCH='glfw vulkan-icd-loader libpng ffmpeg miniupnpc zlib'
PKG_BIN_DEPS_DEB='libgcc1, libglfw3 | libglfw3-wayland, libvulkan1, libpng16-16, libavcodec58 | libavcodec-extra58, libavformat58, libavutil56, libminiupnpc17, zlib1g'
PKG_BIN_DEPS_GENTOO='media-libs/glfw media-libs/vulkan-loader media-libs/libpng media-video/ffmpeg net-libs/miniupnpc sys-libs/zlib'

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
icons_get_from_package 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Set working directory to the directory containing the game binary before running it

# shellcheck disable=SC2016
pattern='s|^cd "$PATH_GAME"$|cd "$PATH_GAME/${APP_EXE%/*}"|'
# shellcheck disable=SC2016
pattern="$pattern"';s|^"\./$APP_EXE"|"./${APP_EXE##*/}"|'
file="${PKG_BIN_PATH}${PATH_BIN}/$GAME_ID"
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "$pattern" "$file"
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
