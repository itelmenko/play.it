#!/usr/bin/env sh
set -o errexit

count="$(find 'play.it-2/games' -type f | wc --lines)"
max_procs="$(nproc)"
max_args="$((count / max_procs + 1))"
for shell in 'sh' 'bash' 'dash' 'ksh'; do
	printf 'Testing game scripts validity using ShellCheck in %s mode…\n' "$shell"
	find 'play.it-2/games' -type f | xargs --max-args="$max_args" --max-procs="$max_procs" shellcheck --exclude=SC2034 --external-sources --shell="$shell"
done

exit 0
