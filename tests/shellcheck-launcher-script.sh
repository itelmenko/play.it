#!/usr/bin/env sh
set -o errexit

WORKDIR=$(mktemp --directory --tmpdir="${TMPDIR:-/tmp}" "play.it-tests.XXXXX")
PLAYIT_SCRIPT=$(realpath "$(dirname "$0")/../play.it")

WINE_INSTALLER_URL='http://downloads.digipen.edu/arcade/downloads/043/Tag_setup.exe'
WINE_ARCHIVE='Tag_setup.exe'
WINE_FILE='usr/local/bin/tag-the-power-of-paint'

NATIVE_INSTALLER_URL=$(curl -X POST 'https://samuraipunk.itch.io/feather/file/321541' | jq -r .url)
NATIVE_ARCHIVE='FruitsOfAFeather2.0_LINUX.zip'
NATIVE_FILE='usr/local/bin/fruits-of-a-feather'

printf 'Testing validity of generated launcher script.\n'

make

printf 'Testing WINE game.\n'
mkdir --parents "$WORKDIR"
(
	cd "$WORKDIR"
	wget "$WINE_INSTALLER_URL"
	"$PLAYIT_SCRIPT" "$WINE_ARCHIVE" --package=arch --compression=none
	tar xf lib32-*_x86_64.pkg.tar
)
file="$WORKDIR/$WINE_FILE"
for shell in 'sh' 'bash' 'dash' 'ksh'; do
	printf 'Testing using ShellCheck in %s mode…\n' "$file" "$shell"
	shellcheck --shell="$shell" "$file"
done
rm --force --recursive "${WORKDIR:?}"

printf 'Testing native game.\n'
mkdir --parents "$WORKDIR"
(
	cd "$WORKDIR"
	wget "$NATIVE_INSTALLER_URL" -O "$NATIVE_ARCHIVE"
	"$PLAYIT_SCRIPT" "$NATIVE_ARCHIVE" --package=arch --compression=none
	tar xf fruits-of-a-feather_*_any.pkg.tar
)
file="$WORKDIR/$NATIVE_FILE"
for shell in 'sh' 'bash' 'dash' 'ksh'; do
	printf 'Testing using ShellCheck in %s mode…\n' "$file" "$shell"
	shellcheck --shell="$shell" "$file"
done
rm --force --recursive "${WORKDIR:?}"

exit 0
