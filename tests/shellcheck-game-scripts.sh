#!/usr/bin/env sh
set -o errexit

for file in play.it-2/games/*; do
	for shell in 'sh' 'bash' 'dash' 'ksh'; do
		printf 'Testing %s validity using ShellCheck in %s mode…\n' "$file" "$shell"
		shellcheck --exclude=SC2034 --external-sources --shell="$shell" "$file"
	done
done

exit 0
