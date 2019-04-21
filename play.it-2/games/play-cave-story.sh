#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2019, BetaRays
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
# Cave Story
# build native Linux packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190325.1

# Set game-specific variables

GAME_ID='cave-story'
GAME_NAME='Cave Story'

ARCHIVES_LIST='ARCHIVE_WINE_JP ARCHIVE_WINE_EN ARCHIVE_LINUX_EN'

ARCHIVE_WINE_JP='dou_1006.zip'
ARCHIVE_WINE_JP_URL='http://studiopixel.sakura.ne.jp/binaries/dou_1006.zip'
ARCHIVE_WINE_JP_MD5='d7f375aa4918337dbe50f738e5d6f78e'
ARCHIVE_WINE_JP_VERSION='1006'
ARCHIVE_WINE_JP_SIZE='5100'
ARCHIVE_WINE_JP_TYPE='zip'

ARCHIVE_WINE_EN='cavestoryen.zip'
ARCHIVE_WINE_EN_URL='https://www.cavestory.org/downloads/cavestoryen.zip'
ARCHIVE_WINE_EN_MD5='5aad47f1cb72185d6e7f4c8c392f6b6e'
ARCHIVE_WINE_EN_VERSION='1.0'
ARCHIVE_WINE_EN_SIZE='5800'
ARCHIVE_WINE_EN_TYPE='zip'

ARCHIVE_LINUX_EN='linuxdoukutsu-1.01.tar.bz2'
ARCHIVE_LINUX_EN_URL='https://www.cavestory.org/downloads/linuxdoukutsu-1.01.tar.bz2'
ARCHIVE_LINUX_EN_MD5='ec08da7c45419bc7740b8149ec7340cf'
ARCHIVE_LINUX_EN_VERSION='1.01'
ARCHIVE_LINUX_EN_SIZE='5500'
ARCHIVE_LINUX_EN_TYPE='tar'

ARCHIVE_OPTIONAL_LINUX_NODATA='linuxDoukutsu-1.2.zip'
ARCHIVE_OPTIONAL_LINUX_NODATA_URL='https://www.cavestory.org/downloads/linuxDoukutsu-1.2.zip'
ARCHIVE_OPTIONAL_LINUX_NODATA_MD5='e73d7330fba3cc5c15f0eeb239df586f'
ARCHIVE_OPTIONAL_LINUX_NODATA_SIZE='4200'
ARCHIVE_OPTIONAL_LINUX_NODATA_TYPE='zip'

ARCHIVE_OPTIONAL_DOCONFIG_LINUX='DoConfigure-r2.zip'
ARCHIVE_OPTIONAL_DOCONFIG_LINUX_URL='http://www.cavestory.org/downloads/DoConfigure-r2.zip'
ARCHIVE_OPTIONAL_DOCONFIG_LINUX_MD5='9f5e96d5ff9671691b7c8a41f8fa5880'
ARCHIVE_OPTIONAL_DOCONFIG_LINUX_SIZE='300'
ARCHIVE_OPTIONAL_DOCONFIG_LINUX_TYPE='zip'

ARCHIVE_DOC_DATA_PATH_WINE_JP='doukutsu'
ARCHIVE_DOC_DATA_PATH_WINE_EN='CaveStory'
ARCHIVE_DOC_DATA_PATH_LINUX_EN='linuxDoukutsu-1.01/doc'
ARCHIVE_DOC_DATA_FILES='Readme.txt Manual.html Manual readme.txt configfileformat.txt'

ARCHIVE_GAME0_BIN32_PATH_WINE_JP='doukutsu'
ARCHIVE_GAME0_BIN32_PATH_WINE_EN='CaveStory'
ARCHIVE_GAME0_BIN32_PATH_LINUX_EN='linuxDoukutsu-1.01'
ARCHIVE_GAME0_BIN32_FILES_WINE='./Doukutsu.exe'
ARCHIVE_GAME0_BIN32_FILES_LINUX='./doukutsu.bin'

ARCHIVE_GAME1_BIN32_PATH_OPTIONAL_LINUX_NODATA='linuxDoukutsu-1.2'
ARCHIVE_GAME1_BIN32_FILES='./doukutsu_32bits'

ARCHIVE_GAME2_BIN32_PATH_OPTIONAL_DOCONFIG_LINUX='.'
ARCHIVE_GAME2_BIN32_FILES='./DoConfigure'

ARCHIVE_GAME0_BIN64_PATH_OPTIONAL_LINUX_NODATA='linuxDoukutsu-1.2'
ARCHIVE_GAME0_BIN64_FILES='./doukutsu_64bits'

ARCHIVE_GAME1_BIN64_PATH_OPTIONAL_DOCONFIG_LINUX='compilation-output-64'
ARCHIVE_GAME1_BIN64_FILES='DoConfigure'

ARCHIVE_GAME_DATA_PATH_WINE_JP='doukutsu'
ARCHIVE_GAME_DATA_PATH_WINE_EN='CaveStory'
ARCHIVE_GAME_DATA_PATH_LINUX_EN='linuxDoukutsu-1.01'
ARCHIVE_GAME_DATA_FILES='./data'

APP_MAIN_TYPE_WINE='wine'
APP_MAIN_EXE_WINE='Doukutsu.exe'
APP_MAIN_ICON_WINE='Doukutsu.exe'
APP_MAIN_TYPE_LINUX='native'
APP_MAIN_EXE_LINUX_EN_BIN32='doukutsu.bin'
APP_MAIN_EXE_OPTIONAL_LINUX_NODATA_BIN32='doukutsu_32bits'
APP_MAIN_EXE_OPTIONAL_LINUX_NODATA_BIN64='doukutsu_64bits'

APP_CONFIG_ID="${GAME_ID}_config"
APP_CONFIG_NAME="$GAME_NAME - configuration"
APP_CONFIG_CAT='Settings'
APP_CONFIG_TYPE_WINE='wine'
APP_CONFIG_EXE_WINE='DoConfig.exe'
APP_CONFIG_ICON_WINE='DoConfig.exe'
APP_CONFIG_TYPE_OPTIONAL_DOCONFIG_LINUX='native'
APP_CONFIG_EXE_OPTIONAL_DOCONFIG_LINUX='DoConfigure'

PACKAGES_LIST='PKG_BIN32 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS_WINE="$PKG_DATA_ID wine"
PKG_BIN32_DEPS_LINUX_EN="$PKG_DATA_ID wine sdl1.2 glibc"
PKG_BIN32_DEPS_OPTIONAL_LINUX_NODATA="$PKG_DATA_ID sdl1.2 glibc libstdc++"
PKG_BIN32_DEPS_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='freetype glibc xft libstdc++'
PKG_BIN32_DEPS_DEB_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='' # TODO
PKG_BIN32_DEPS_ARCH_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='' # TODO
PKG_BIN32_DEPS_GENTOO_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='x11-libs/libX11[abi_x86_32] x11-libs/libXext[abi_x86_32] x11-libs/libXinerama[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS='glibc libstdc++ sdl1.2'
PKG_BIN64_DEPS_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='glibc libstdc++'
PKG_BIN64_DEPS_DEB_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='' # TODO
PKG_BIN64_DEPS_ARCH_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='' # TODO
PKG_BIN64_DEPS_GENTOO_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX='x11-libs/fltk'

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
# shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_LINUX_PORT' 'ARCHIVE_OPTIONAL_LINUX_NODATA'
ARCHIVE="$ARCHIVE_MAIN"
if [ "$ARCHIVE_LINUX_PORT" ]; then
	ARCHIVE_GAME1_BIN32_PATH="$ARCHIVE_GAME1_BIN32_PATH_OPTIONAL_LINUX_NODATA"
	ARCHIVE_GAME0_BIN64_PATH="$ARCHIVE_GAME0_BIN64_PATH_OPTIONAL_LINUX_NODATA"
	APP_MAIN_TYPE="$APP_MAIN_TYPE_LINUX"
	APP_MAIN_EXE_BIN32="$APP_MAIN_EXE_OPTIONAL_LINUX_NODATA_BIN32"
	APP_MAIN_EXE_BIN64="$APP_MAIN_EXE_OPTIONAL_LINUX_NODATA_BIN64"
	PKG_BIN32_DEPS="$PKG_DATA_ID $PKG_BIN32_DEPS_OPTIONAL_LINUX_NODATA"
	PACKAGES_LIST="$PACKAGES_LIST PKG_BIN64"
	select_package_architecture
	set_temp_directories $PACKAGES_LIST
fi

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_DOCONFIG_LINUX' 'ARCHIVE_OPTIONAL_DOCONFIG_LINUX'
ARCHIVE="$ARCHIVE_MAIN"
if [ "$ARCHIVE_DOCONFIG_LINUX" ]; then
	ARCHIVE_GAME2_BIN32_PATH="$ARCHIVE_GAME2_BIN32_PATH_OPTIONAL_DOCONFIG_LINUX"
	ARCHIVE_GAME1_BIN64_PATH="$ARCHIVE_GAME1_BIN64_PATH_OPTIONAL_DOCONFIG_LINUX"
	APP_CONFIG_TYPE="$APP_CONFIG_TYPE_OPTIONAL_DOCONFIG_LINUX"
	APP_CONFIG_EXE="$APP_CONFIG_EXE_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN32_DEPS="$PKG_BIN32_DEPS $PKG_BIN32_DEPS_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN32_DEPS_DEB="$PKG_BIN32_DEPS_DEB $PKG_BIN32_DEPS_DEB_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN32_DEPS_ARCH="$PKG_BIN32_DEPS_ARCH $PKG_BIN32_DEPS_ARCH_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN32_DEPS_GENTOO="$PKG_BIN32_DEPS_GENTOO $PKG_BIN32_DEPS_GENTOO_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN64_DEPS="$PKG_BIN64_DEPS $PKG_BIN64_DEPS_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN64_DEPS_DEB="$PKG_BIN64_DEPS_DEB $PKG_BIN64_DEPS_DEB_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN64_DEPS_ARCH="$PKG_BIN64_DEPS_ARCH $PKG_BIN64_DEPS_ARCH_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
	PKG_BIN64_DEPS_GENTOO="$PKG_BIN64_DEPS_GENTOO $PKG_BIN64_DEPS_GENTOO_ADDITIONAL_OPTIONAL_DOCONFIG_LINUX"
fi

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

set_standard_permissions "$PLAYIT_WORKDIR/gamedata"

prepare_package_layout

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

case "$ARCHIVE" in
	('ARCHIVE_WINE_'*)
		PKG='PKG_BIN32'
		icons_get_from_package 'APP_MAIN'
		icons_move_to 'PKG_DATA'
	;;
esac

# Include Linux port

if [ "$ARCHIVE_LINUX_PORT" ]; then
	(
		ARCHIVE='ARCHIVE_LINUX_PORT'
		extract_data_from "$ARCHIVE_LINUX_PORT"
	)
	prepare_package_layout
fi

# Extract (and compile if needed) the native version of DoConfig

if [ "$ARCHIVE_DOCONFIG_LINUX" ]; then
	extract_data_from "$ARCHIVE_DOCONFIG_LINUX"
	for pkg in $PACKAGES_LIST; do
		if [ "$pkg" = 'PKG_BIN64' ]; then
			[ -e '/usr/include/FL/Fl.H' ] || [ -e '/usr/include/fltk/FL/Fl.H' ] || check_deps_error_not_found 'fltk'
			if command -v g++ >/dev/null && LANG=C g++ -v 2>&1 | grep '^Target: x86_64' >/dev/null; then
				compiler='g++'
			elif command -v clang++ >/dev/null && LANG=C clang++ -v 2>&1 | grep '^Target: x86_64' >/dev/null; then
				compiler='clang++'
			else
				check_deps_error_not_found 'gcc/clang x86_64'
			fi
			[ -d "$PLAYIT_WORKDIR/gamedata/compilation-output-64" ] || mkdir "$PLAYIT_WORKDIR/gamedata/compilation-output-64"
			packages_guess_format 'distro' 2>/dev/null
			# shellcheck disable=SC2154
			case "$distro" in
				('deb')
					#TODO
				;;
				('arch')
					#TODO
				;;
				('gentoo')
					libdir_64="/usr/$(portageq envvar LIBDIR_amd64)"
				;;
			esac
			"$compiler" -B"${libdir_64}/fltk" -lfltk -I/usr/include/fltk "$PLAYIT_WORKDIR/gamedata/$ARCHIVE_GAME2_BIN32_PATH/DoConfig.cpp" -o "$PLAYIT_WORKDIR/gamedata/compilation-output-64/DoConfigure"
		fi
	done
	prepare_package_layout
	rm --recursive "$PLAYIT_WORKDIR/gamedata"
fi

# Write launchers

PKG='PKG_BIN32'
write_launcher 'APP_MAIN' 'APP_CONFIG'
if [ "$ARCHIVE_LINUX_PORT" ]; then
	PKG='PKG_BIN64'
	write_launcher 'APP_MAIN'
fi
if [ "$ARCHIVE_DOCONFIG_LINUX" ]; then
	for PKG in $PACKAGES_LIST; do
		if [ "$PKG" = 'PKG_BIN64' ]; then
			write_launcher 'APP_CONFIG'
		fi
	done
fi

# Build package

write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32'
if [ "$ARCHIVE_LINUX_PORT" ]; then
	write_metadata 'PKG_BIN64'
fi
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
