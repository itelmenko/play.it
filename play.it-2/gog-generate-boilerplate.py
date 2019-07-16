#!/usr/bin/env python3

from argparse import ArgumentParser
from datetime import datetime
from hashlib import md5
import os
from pathlib import Path
import re
import shutil
from subprocess import check_output, CalledProcessError
import sys
from typing import Set, Iterable
from zipfile import ZipFile


def fill_hash():
    hasher = md5()

    with installer.open('rb') as fp:
        while True:
            buf = fp.read(1 << 20)
            if not buf:
                break
            hasher.update(buf)

    env['ARCHIVE_GOG_MD5'] = hasher.hexdigest()


def fill_conf():
    out = check_output(['sh', str(installer), '--dumpconf']).decode('utf-8').strip()
    d = {
        line.partition('=')[0]: line.partition('=')[2]
        for line in out.split('\n')
    }
    assert './startmojo.sh' in d['SCRIPT']
    env['GAME_NAME'] = d['LABEL'].replace('(GOG.com)', '').strip('"').strip()


def fill_from_gameinfo(extracted: Path):
    text = extracted.joinpath('data/noarch/gameinfo').read_text()
    m = re.match(r'''
        (?P<name>.+)\n
        (?P<version>\d.+)\n
        (?P<gversion>.+)\n
    ''', text, flags=re.X | re.I)
    if not m:
        raise NotImplementedError('gameinfo format not recognized')

    gversion = m['gversion']
    if gversion == 'n/a':  # example: hotline miami
        gversion = '1'
    else:
        assert re.fullmatch(r'\d+(\.\d+)*', gversion)

    version = m['version']
    if ' ' in version:
        version = version.replace(' ', '.')  # example: broforce
    assert re.fullmatch(r'\d+(\.\d+)*', version)

    env['GAME_NAME'] = m['name']
    env['ARCHIVE_GOG_VERSION'] = f'{version}-gog{gversion}'

    du_out = check_output(['du', '-s', extracted]).decode('utf-8')
    size_kb = int(re.match(r'(\d+)\s', du_out)[1])
    env['ARCHIVE_GOG_SIZE'] = str(size_kb * 1024)


def fill_developer():
    filler = 'FILL ME'
    env['dev_name'] = filler
    env['dev_email'] = filler
    try:
        env['dev_name'] = check_output(['git', 'config', 'user.name']).decode('utf-8').strip() or filler
        env['dev_email'] = check_output(['git', 'config', 'user.email']).decode('utf-8').strip() or filler
    except CalledProcessError:
        pass


def extract() -> Path:
    tmpdir = os.environ.get('TMPDIR') or '/tmp'
    dest = Path(tmpdir).joinpath(f'playit-extract-{installer.stem}')

    mojosize = 0
    headlines = 0

    headlines_re = re.compile(br'\s*offset=`head -n (\d+)')
    mojosize_re = re.compile(br'filesizes="(\d+)')

    with installer.open('rb') as fp:
        for nline, line in enumerate(fp, 1):
            if not mojosize:
                m = mojosize_re.match(line)
                if m:
                    mojosize = int(m[1])
            elif not headlines:
                m = headlines_re.match(line)
                if m:
                    headlines = int(m[1])
            else:
                for _ in range(nline, headlines):
                    fp.readline()
                break

        shellsize = fp.tell()
        fp.seek(shellsize + mojosize)

        try:
            dest.mkdir()
        except FileExistsError:
            print(f'{dest} already exists, not extracting', file=sys.stderr)
        else:
            try:
                print(f'{dest} does not exist, extracting archive...', file=sys.stderr)
                ZipFile(fp).extractall(path=dest)
            except Exception:
                shutil.rmtree(str(dest))
                raise

    return dest


def get_arch(path):
    out = check_output(['file', str(path)]).decode('utf-8')
    if 'ELF 64-bit' in out:
        return 64
    elif 'ELF 32-bit' in out:
        return 32


def find_binaries(path: Path) -> Set[Path]:
    files = {}
    files[32] = [
        *path.rglob('**/*x86'),
        *path.rglob('**/*x86.*'),
        *path.rglob('**/lib/**'),
    ]
    files[64] = [
        *path.rglob('**/*x86_64'),
        *path.rglob('**/*x86_64.*'),
        *path.rglob('**/lib64/**'),
    ]

    for arch in (32, 64):
        # expand dirs
        for f in files[arch]:
            if f.is_dir():
                files[arch].extend(f.rglob('**/*'))
        # discard dirs
        files[arch] = [f for f in files[arch] if not f.is_dir()]

    # search lost .so files
    for so in [*path.rglob('**/*.so'), *path.rglob('**/*.so.*')]:
        arch = get_arch(so)
        if arch:
            files[arch].append(so)

    for arch in (32, 64):
        # make a set
        files[arch] = set(files[arch])

    if not files[32] and not files[64]:
        raise NotImplementedError('oops, arch not detected')

    return files


def is_ancestor_of(ancestor: Path, child: Path) -> bool:
    try:
        child.relative_to(ancestor)
    except ValueError:
        return False
    return True


def get_simple_paths_in(root: Path, excluded: Set[Path]) -> Set[Path]:
    """Return all files within `root` without `excluded`, in a simple form.

    Simplify: if a directory contain no excluded file, take the directory instead.
    """

    poisoned = set(
        par
        for excl in excluded
        for par in excl.parents
        if is_ancestor_of(root, par)
    )

    lone_files = set(
        entry
        for dir in poisoned
        for entry in dir.iterdir()
        if entry.is_file()
    ) - excluded

    all_dirs = set(entry for entry in root.rglob('**/*') if entry.is_dir())

    safe_dirs = all_dirs - poisoned
    safe_dirs = set(d for d in safe_dirs if d.parent not in safe_dirs)

    return try_get_wildcards(lone_files) | safe_dirs


def get_simpler_paths(paths: Iterable[Path]) -> Set[Path]:
    """Return all files from `paths` but in simpler form.

    Simplify: if a directory contain no excluded file, take the directory instead.
    """

    parents = set(p.parent for p in paths)
    parents_content = set(sub for par in parents for sub in par.iterdir())

    unwanted = parents_content - paths
    simplifiable_parents = parents - set(p.parent for p in unwanted)

    lone_files = set(p for p in paths if p.parent not in simplifiable_parents)
    return try_get_wildcards(lone_files) | simplifiable_parents


def set_groupby(objs: Iterable, keyfunc) -> dict:
    d = {}
    for obj in objs:
        key = keyfunc(obj)
        try:
            d[key].add(obj)
        except KeyError:
            d[key] = set()
            d[key].add(obj)

    return d


def try_get_wildcards(in_paths: Set[Path]) -> Set[Path]:
    to_add = set()
    to_remove = set()

    by_parent = set_groupby(in_paths, lambda p: p.parent)

    for par, subs in by_parent.items():
        by_ext = set_groupby(par.iterdir(), lambda p: p.suffix)
        by_ext.pop('', None)  # can't do wildcard if there's no extension

        for ext, ext_paths in by_ext.items():
            unwanted_files = ext_paths - in_paths

            if not unwanted_files:
                can_be_removed = ext_paths & in_paths
                if len(can_be_removed) > 1:  # only do it if it's worth it
                    to_remove |= can_be_removed
                    to_add.add(par.joinpath(f'*{ext}'))

    return (in_paths | to_add) - to_remove


SIMPLE_DEPS = """
    alsa
    bzip2
    dosbox
    freetype
    gcc32
    gconf
    glibc
    glu
    glx
    gtk2
    java
    json
    libcurl
    libcurl-gnutls
    libstdc++
    libudev1
    libxrandr
    nss
    openal
    pulseaudio
    sdl1.2
    sdl2
    sdl2_image
    sdl2_mixer
    theora
    vorbis
    xcursor
    xft
    xgamma
    xrandr
""".split()


def find_dependencies_basic(f: Path) -> Iterable[str]:
    """Return base play.it dependencies, not packages names"""

    out = check_output(['ldd', f]).decode('utf-8').strip()
    sodeps = set(
        line.strip().split()[0]
        for line in out.split('\n')
    )
    simple = set(
        dep
        for so in sodeps
        for dep in SIMPLE_DEPS
        if dep in so.lower()
    )
    return simple


def fix_filename(n: str) -> str:
    return n.replace(' ', '?')


def fill_files(path: Path) -> None:
    env['ARCHIVE_DOC_DATA_PATH'] = 'data/noarch/docs'
    env['ARCHIVE_DOC_DATA_FILES'] = './*'

    bins = find_binaries(path)
    for arch in (32, 64):
        # env[f'APP_MAIN_EXE_BIN{arch}']
        env[f'ARCHIVE_GAME_BIN{arch}_PATH'] = 'data/noarch/game'

        env[f'ARCHIVE_GAME_BIN{arch}_FILES'] = ' '.join(
            fix_filename(str(bin.relative_to(path)))
            for bin in sorted(get_simpler_paths(bins[arch]))
        )
        env[f'PKG_BIN{arch}_ARCH'] = str(arch)
        env[f'PKG_BIN{arch}_DEPS'] = ' '.join(sorted(set(
            s
            for f in bins[arch]
            for s in find_dependencies_basic(f)
        )))

        exes = [f for f in bins[arch] if f.parent == path]
        if len(exes) == 1:
            env[f'APP_MAIN_EXE_BIN{arch}'] = str(exes[0].relative_to(path))
        else:
            env[f'APP_MAIN_EXE_BIN{arch}'] = 'FILL ME'

    env['ARCHIVE_GAME_DATA_PATH'] = 'data/noarch/game'
    env['ARCHIVE_GAME_DATA_FILES'] = ' '.join(sorted(
        fix_filename(str(f.relative_to(path)))
        for f in get_simple_paths_in(path, bins[32] | bins[64])
    ))

    env['_PKGS'] = ' '.join(f'PKG_BIN{arch}' for arch in [32, 64] if bins[arch])


TEMPLATE = r"""#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2018-%(copyleft_year)s, %(dev_name)s
# Copyright (c) 2015-%(copyleft_year)s, Antoine "vv221/vv222" Le Gonidec
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
# %(GAME_NAME)s
# build native Linux packages from the original installers
# send your bug reports to %(dev_email)s
###

script_version=%(script_version)s

# Set game-specific variables

GAME_ID='%(GAME_ID)s'
GAME_NAME='%(GAME_NAME)s'

ARCHIVE_GOG='%(ARCHIVE_GOG)s'
ARCHIVE_GOG_URL='%(ARCHIVE_GOG_URL)s'
ARCHIVE_GOG_MD5='%(ARCHIVE_GOG_MD5)s'
ARCHIVE_GOG_SIZE='%(ARCHIVE_GOG_SIZE)s'
ARCHIVE_GOG_VERSION='%(ARCHIVE_GOG_VERSION)s'
ARCHIVE_GOG_TYPE='%(ARCHIVE_GOG_TYPE)s'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='./*'

ARCHIVE_GAME_BIN32_PATH='%(ARCHIVE_GAME_BIN32_PATH)s'
ARCHIVE_GAME_BIN32_FILES='%(ARCHIVE_GAME_BIN32_FILES)s'

ARCHIVE_GAME_BIN64_PATH='%(ARCHIVE_GAME_BIN64_PATH)s'
ARCHIVE_GAME_BIN64_FILES='%(ARCHIVE_GAME_BIN64_FILES)s'

ARCHIVE_GAME_DATA_PATH='%(ARCHIVE_GAME_DATA_PATH)s'
ARCHIVE_GAME_DATA_FILES='%(ARCHIVE_GAME_DATA_FILES)s'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='%(APP_MAIN_EXE_BIN32)s'
APP_MAIN_EXE_BIN64='%(APP_MAIN_EXE_BIN64)s'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA %(_PKGS)s'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='%(PKG_BIN32_ARCH)s'
PKG_BIN32_DEPS="$PKG_DATA_ID %(PKG_BIN32_DEPS)s"

PKG_BIN64_ARCH='%(PKG_BIN64_ARCH)s'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in %(_PKGS)s; do
        write_launcher 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "${PLAYIT_WORKDIR}"

# Print instructions

print_instructions

exit 0
"""


env = {}


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('--debug')
    parser.add_argument('installer')
    parser.add_argument('game_id')

    args = parser.parse_args()

    installer = Path(args.installer)
    env['GAME_ID'] = args.game_id
    env['script_version'] = datetime.now().strftime('%Y%m%d.1')
    env['copyleft_year'] = datetime.now().strftime('%Y')
    env['ARCHIVE_GOG_URL'] = f'https://www.gog.com/game/{env["GAME_ID"]}'

    assert installer.is_file()

    env['ARCHIVE_GOG'] = installer.name
    env['ARCHIVE_GOG_TYPE'] = 'mojosetup'
    fill_hash()
    fill_conf()
    fill_developer()

    extracted = extract()
    fill_from_gameinfo(extracted)

    noarch = extracted / 'data' / 'noarch' / 'game'
    fill_files(noarch)

    if args.debug:
        print(env)
    else:
        target = Path(__file__).parent.joinpath('games').joinpath('play-%s.sh' % env['GAME_ID'])
        with target.open('w') as fd:
            print(TEMPLATE % env, file=fd)
