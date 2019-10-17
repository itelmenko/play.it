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
# Doki Doki Literature Club
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190911.7

# Set game-specific variables

GAME_ID='doki-doki-literature-club'
GAME_NAME='Doki Doki Literature Club'

ARCHIVE_ITCH='ddlc-win.zip'
ARCHIVE_ITCH_URL='https://teamsalvato.itch.io/ddlc'
ARCHIVE_ITCH_MD5='09a4e1bf2ab801908b3199f901bd8b0d'
ARCHIVE_ITCH_SIZE='280000'
ARCHIVE_ITCH_VERSION='1.1.1-itch1'

ARCHIVE_OPTIONAL_FR='Yarashii - Doki Doki Literature Club! Patch FR.zip'
ARCHIVE_OPTIONAL_FR_URL='https://www.yarashii.fr/ddlc'
ARCHIVE_OPTIONAL_FR_MD5='14ba98f055f0d99a4639bbf41ecec850'
ARCHIVE_OPTIONAL_FR_SIZE='490000'

ARCHIVE_OPTIONAL_RPATOOL='rpatool'
ARCHIVE_OPTIONAL_RPATOOL_URL='https://github.com/Shizmob/rpatool'
ARCHIVE_OPTIONAL_RPATOOL_MD5='bd65fd3bc7461e35b41e294ada53a876'
ARCHIVE_OPTIONAL_RPATOOL_TYPE='file'

ARCHIVE_DOC_DATA_PATH='DDLC-1.1.1-pc'
ARCHIVE_DOC_DATA_FILES='COPYRIGHT.txt'

ARCHIVE_GAME_BIN32_PATH='DDLC-1.1.1-pc'
ARCHIVE_GAME_BIN32_FILES='lib/linux-i686'

ARCHIVE_GAME_BIN64_PATH='DDLC-1.1.1-pc'
ARCHIVE_GAME_BIN64_FILES='lib/linux-x86_64'

ARCHIVE_GAME_DATA_PATH='DDLC-1.1.1-pc'
ARCHIVE_GAME_DATA_FILES='characters game renpy DDLC.py lib/pythonlib2.7 README.html'

DATA_DIRS='game/saves'
DATA_FILES='game/firstrun log.txt'

APP_MAIN_TYPE='native'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='cp --remove-destination "$PATH_GAME/DDLC.py" "$PATH_PREFIX"'
APP_MAIN_EXE_BIN32='lib/linux-i686/DDLC'
APP_MAIN_EXE_BIN64='lib/linux-x86_64/DDLC'
APP_MAIN_OPTIONS='-EO DDLC.py'
APP_MAIN_ICON='DDLC-1.1.1-pc/DDLC.exe'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc"

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

ARCHIVE_MAIN="$ARCHIVE"
archive_set 'ARCHIVE_FR' 'ARCHIVE_OPTIONAL_FR'
if [ "$ARCHIVE_FR" ]; then
	archive_set 'ARCHIVE_RPATOOL' 'ARCHIVE_OPTIONAL_RPATOOL'
	if [ "$ARCHIVE_RPATOOL" ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS python"
		check_deps
	else
		ARCHIVE_FR=
		#TODO: print warning
	fi
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
set_standard_permissions "$PLAYIT_WORKDIR/gamedata"
if [ "$ARCHIVE_FR" ]; then
	extract_data_from "$ARCHIVE_FR"

	# Fix encoding of poem words for the game to run

	python "$ARCHIVE_RPATOOL" -o "$PLAYIT_WORKDIR/gamedata" -x "$PLAYIT_WORKDIR/gamedata/Yarashii - Doki Doki Literature Club! Patch FR/game/scripts.rpa" poemwords.txt
	contents="$(iconv --from-code WINDOWS-1252 --to-code UTF-8 "$PLAYIT_WORKDIR/gamedata/poemwords.txt")"
	printf '%s' "$contents" > "$PLAYIT_WORKDIR/gamedata/poemwords.txt"
	python "$ARCHIVE_RPATOOL" -d "$PLAYIT_WORKDIR/gamedata/Yarashii - Doki Doki Literature Club! Patch FR/game/scripts.rpa" poemwords.txt
	python "$ARCHIVE_RPATOOL" -a "$PLAYIT_WORKDIR/gamedata/Yarashii - Doki Doki Literature Club! Patch FR/game/scripts.rpa" "poemwords.txt=$PLAYIT_WORKDIR/gamedata/poemwords.txt"

	# Replace game files

	use_archive_specific_value 'ARCHIVE_GAME_DATA_PATH'
	(cd "$PLAYIT_WORKDIR/gamedata/Yarashii - Doki Doki Literature Club! Patch FR" && find . -type f -exec sh -c 'mkdir --parents "$PLAYIT_WORKDIR/gamedata/$2/$(dirname "$1" | sed "s#^\./##")" && mv "$1" "$PLAYIT_WORKDIR/gamedata/$2/$(printf %s "$1" | sed "s#^\./##")"' -- '{}' "$ARCHIVE_GAME_DATA_PATH" \;)
fi
prepare_package_layout

# Extract game icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

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
