# check script dependencies
# USAGE: check_deps
# NEEDED VARS: (ARCHIVE) (ARCHIVE_TYPE) (OPTION_CHECKSUM) (OPTION_PACKAGE) (SCRIPT_DEPS)
# CALLS: check_deps_7z check_deps_error_not_found icons_list_dependencies
check_deps() {
	icons_list_dependencies
	if [ "$ARCHIVE" ]; then
		case "$(get_value "${ARCHIVE}_TYPE")" in
			('cabinet')
				SCRIPT_DEPS="$SCRIPT_DEPS cabextract"
			;;
			('innosetup1.7'*)
				SCRIPT_DEPS="$SCRIPT_DEPS innoextract1.7"
			;;
			('innosetup'*)
				SCRIPT_DEPS="$SCRIPT_DEPS innoextract"
			;;
			('nixstaller')
				SCRIPT_DEPS="$SCRIPT_DEPS gzip tar unxz"
			;;
			('msi')
				SCRIPT_DEPS="$SCRIPT_DEPS msiextract"
			;;
			('mojosetup'|'iso')
				SCRIPT_DEPS="$SCRIPT_DEPS bsdtar"
			;;
			('rar'|'nullsoft-installer')
				SCRIPT_DEPS="$SCRIPT_DEPS unar"
			;;
			('tar')
				SCRIPT_DEPS="$SCRIPT_DEPS tar"
			;;
			('tar.gz')
				SCRIPT_DEPS="$SCRIPT_DEPS gzip tar"
			;;
			('zip'|'zip_unclean'|'mojosetup_unzip')
				SCRIPT_DEPS="$SCRIPT_DEPS unzip"
			;;
		esac
	fi
	if [ "$OPTION_CHECKSUM" = 'md5sum' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS md5sum"
	fi
	if [ "$OPTION_PACKAGE" = 'deb' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot dpkg"
	fi
	if [ "$OPTION_PACKAGE" = 'gentoo' ]; then
		# fakeroot doesn't work for me, only fakeroot-ng does
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot-ng ebuild"
	fi
	for dep in $SCRIPT_DEPS; do
		case $dep in
			('7z')
				check_deps_7z
			;;
			('innoextract'*)
				check_deps_innoextract "$dep"
			;;
			('debian')
				check_deps_deb
			;;
			(*)
				if ! command -v "$dep" >/dev/null 2>&1; then
					check_deps_error_not_found "$dep"
				fi
			;;
		esac
	done
}

# check presence of a software to handle .7z archives
# USAGE: check_deps_7z
# CALLS: check_deps_error_not_found
# CALLED BY: check_deps
check_deps_7z() {
	if command -v 7zr >/dev/null 2>&1; then
		extract_7z() { 7zr x -o"$2" -y "$1"; }
	elif command -v 7za >/dev/null 2>&1; then
		extract_7z() { 7za x -o"$2" -y "$1"; }
	elif command -v unar >/dev/null 2>&1; then
		extract_7z() { unar -output-directory "$2" -force-overwrite -no-directory "$1"; }
	else
		check_deps_error_not_found 'p7zip'
	fi
}

# check innoextract presence, optionally in a given minimum version
# USAGE: check_deps_innoextract $keyword
# CALLS: check_deps_error_not_found
# CALLED BYD: check_deps
check_deps_innoextract() {
	local keyword
	local name
	local version
	local version_major
	local version_minor
	keyword="$1"
	case "$keyword" in
		('innoextract1.7')
			name='innoextract (>= 1.7)'
		;;
		(*)
			name='innoextract'
		;;
	esac
	if ! command -v 'innoextract' >/dev/null 2>&1; then
		check_deps_error_not_found "$name"
	fi
	version="$(innoextract --version | head --lines=1 | cut --delimiter=' ' --fields=2)"
	version_minor="${version#*.}"
	version_major="${version%.*}"
	case "$keyword" in
		('innoextract1.7')
			if
				[ "$version_major" -lt 1 ] || \
				[ "$version_major" -lt 2 ] && [ "$version_minor" -lt 7 ]
			then
				check_deps_error_not_found "$name"
			fi
		;;
	esac
	return 0
}

# display a message if a required dependency is missing
# USAGE: check_deps_error_not_found $command_name
# CALLED BY: check_deps check_deps_7z
check_deps_error_not_found() {
	print_error
	case "${LANG%_*}" in
		('fr')
			string='%s est introuvable. Installez-le avant de lancer ce script.\n'
		;;
		('en'|*)
			string='%s not found. Install it before running this script.\n'
		;;
	esac
	printf "$string" "$1"
	return 1
}

# check presence of a software to handle .deb archives
# USAGE: check_deps_deb
# CALLS: check_deps_error_not_found
# CALLED BY: check_deps
check_deps_deb() {
	if command -v dpkg-deb >/dev/null 2>&1; then
		extract_deb() { dpkg-deb --extract "$1" "$2"; }
	elif command -v bsdtar >/dev/null 2>&1; then
		extract_deb() { bsdtar --extract --to-stdout --file "$1" 'data*' | bsdtar --directory "$2" --extract --file /dev/stdin; }
	elif command -v unar >/dev/null 2>&1; then
		extract_deb() {
			[ -d "$PLAYIT_WORKDIR/extraction" ] || mkdir "$PLAYIT_WORKDIR/extraction"
			unar -output-directory "$PLAYIT_WORKDIR/extraction" -force-overwrite -no-directory "$1" 'data*'
			unar -output-directory "$2" -force-overwrite -no-directory "$PLAYIT_WORKDIR/extraction"/data*
			rm --recursive --force "$PLAYIT_WORKDIR/extraction"
		}
	elif command -v tar >/dev/null 2>&1; then
		if command -v 7z >/dev/null 2>&1; then
			extract_deb() {
				7z x -i'!data*' -so "$1" | tar --directory "$2" --extract
			}
		elif command -v 7zr >/dev/null 2>&1; then
			extract_deb() {
				7zr x -so "$1" | tar --directory "$2" --extract
			}
		elif command -v ar >/dev/null 2>&1; then
			extract_deb() {
				[ -d "$PLAYIT_WORKDIR/extraction" ] || mkdir "$PLAYIT_WORKDIR/extraction"
				(
					cd "$PLAYIT_WORKDIR/extraction"
					ar x "$1" "$(ar l "$1" | grep ^data)"

				)
				tar --directory "$2" --extract --file "$PLAYIT_WORKDIR/extraction"/data*
				rm --recursive --force "$PLAYIT_WORKDIR/extraction"
			}
		fi
	else
		check_deps_error_not_found 'dpkg-deb/bsdtar/unar/tar'
	fi
}

