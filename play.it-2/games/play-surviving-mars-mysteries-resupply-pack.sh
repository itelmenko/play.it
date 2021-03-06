#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2019, Janeene "dawnmist" Beeforth
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
# Mysteries Resupply Pack for Surviving Mars.
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20181005.1

# Set game-specific variables

# copy GAME_ID from play-surviving-mars.sh
GAME_ID='surviving-mars'
GAME_NAME='Surviving Mars: Mysteries Resupply Pack'


ARCHIVE_GOG='surviving_mars_mysteries_resupply_pack_sagan_rc3_update_24111.sh'
ARCHIVE_GOG_MD5='042fc7152f3ad72e0c121dfb96f617d8'
ARCHIVE_GOG_SIZE='3100'
ARCHIVE_GOG_VERSION='24111'
ARCHIVE_GOG_TYPE='mojosetup_unzip'
ARCHIVE_GOG_URL='https://www.gog.com/game/surviving_mars_mysteries_resupply_pack'

ARCHIVE_GOG_OLD3='surviving_mars_mysteries_resupply_pack_sagan_rc1_update_23676.sh'
ARCHIVE_GOG_OLD3_MD5='e7e96c1384fd795f4a9b69db579524e6'
ARCHIVE_GOG_OLD3_SIZE='3100'
ARCHIVE_GOG_OLD3_VERSION='23676'
ARCHIVE_GOG_OLD3_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD2='surviving_mars_mysteries_resupply_pack_en_davinci_rc1_22763.sh'
ARCHIVE_GOG_OLD2_MD5='6e83b67c5d368c25092ecb4fd700b5ae'
ARCHIVE_GOG_OLD2_SIZE='3100'
# switching to the build number directly in future
ARCHIVE_GOG_OLD2_VERSION='22763'
ARCHIVE_GOG_OLD2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD1='surviving_mars_mysteries_resupply_pack_en_180619_curiosity_hotfix_3_21661.sh'
ARCHIVE_GOG_OLD1_MD5='fd7ef79614de264ac4eb2a1e431d64bf'
ARCHIVE_GOG_OLD1_SIZE='2900'
ARCHIVE_GOG_OLD1_VERSION='3-gog21661'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD0='surviving_mars_mysteries_resupply_pack_en_curiosity_2_21442.sh'
ARCHIVE_GOG_OLD0_MD5='9ca47c2cdb5a41cf8b221dca99783916'
ARCHIVE_GOG_OLD0_SIZE='2900'
ARCHIVE_GOG_OLD0_VERSION='2-gog21442'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='DLC'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-mysteries-resupply-pack"
PKG_MAIN_DEPS="$GAME_ID"

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
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
