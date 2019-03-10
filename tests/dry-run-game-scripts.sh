#!/bin/sh
set -o errexit

tests_directory=$(dirname "$0")
find 'play.it-2/games' -type f -exec "$tests_directory/dry-run-single-script.sh" '{}' \;

exit 0
