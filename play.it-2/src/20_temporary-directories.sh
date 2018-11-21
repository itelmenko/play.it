# get default temporary dir
# USAGE: get_tmp_dir
get_tmp_dir() {
	printf '%s' "${TMPDIR:-/tmp}"
	return 0
}

# set temporary directories
# USAGE: set_temp_directories $pkg[…]
# NEEDED VARS: (ARCHIVE_SIZE) GAME_ID (LANG) (PWD) (XDG_CACHE_HOME) (XDG_RUNTIME_DIR)
# CALLS: set_temp_directories_error_no_size set_temp_directories_error_not_enough_space set_temp_directories_pkg testvar get_tmp_dir
set_temp_directories() {
	local base_directory
	local free_space
	local needed_space
	local tmpdir
	local -n directory
	local directory_candidates

	# If $PLAYIT_WORKDIR is already set, delete it before setting a new one
	[ "$PLAYIT_WORKDIR" ] && rm --force --recursive "$PLAYIT_WORKDIR"

	# If there is only a single package, make it the default one for the current instance
	[ $# = 1 ] && PKG="$1"

	# Look for a directory with enough free space to work in
	if [ "$ARCHIVE_SIZE" ]; then
		needed_space=$((ARCHIVE_SIZE * 2))
	else
		set_temp_directories_error_no_size
	fi
	tmpdir="$(get_tmp_dir)"
	unset base_directory
	if [ $OPTION_PACKAGE == raw ]; then
		directory_candidates=OPTION_PREFIX
	else
		[ "$XDG_RUNTIME_DIR" ] || XDG_RUNTIME_DIR="/run/user/$(id -u)"
		[ "$XDG_CACHE_HOME" ]  || XDG_CACHE_HOME="$HOME/.cache"
		eval directory_candidates=\"XDG_RUNTIME_DIR \
						tmpdir \
						XDG_CACHE_HOME \
						PWD\"
	fi
	for directory in $directory_candidates
	do
		free_space=$(df --output=avail "$directory" 2>/dev/null | tail --lines=1)
		if [ -w "$directory" ] && [ $free_space -ge $needed_space ]; then
			base_directory="$directory/play.it"
			if [ "$directory" = "$tmpdir" ]; then
				if [ ! -e "$base_directory" ]; then
					mkdir --parents "$base_directory"
					chmod 777 "$base_directory"
				fi
			fi
			break;
		fi
	done
	if [ -n "$base_directory" ]; then
		mkdir --parents "$base_directory"
	else
		set_temp_directories_error_not_enough_space
	fi

	# Generate a directory with a unique name for the current instance
	PLAYIT_WORKDIR="$(mktemp --directory --tmpdir="$base_directory" "${GAME_ID}.XXXXX")"
	export PLAYIT_WORKDIR

	# Set $postinst and $prerm
	mkdir --parents "$PLAYIT_WORKDIR/scripts"
	postinst="$PLAYIT_WORKDIR/scripts/postinst"
	export postinst
	prerm="$PLAYIT_WORKDIR/scripts/prerm"
	export prerm

	# Set temporary directories for each package to build
	for pkg in "$@"; do
		testvar "$pkg" 'PKG'
		set_temp_directories_pkg $pkg
	done
}

# set package-secific temporary directory
# USAGE: set_temp_directories_pkg $pkg
# NEEDED VARS: (ARCHIVE) (OPTION_PACKAGE) PLAYIT_WORKDIR (PKG_ARCH) PKG_ID|GAME_ID
# CALLED BY: set_temp_directories
set_temp_directories_pkg() {
	PKG="$1"

	if [ $OPTION_PACKAGE != raw ]; then
		# Get package ID
		use_archive_specific_value "${PKG}_ID"
		local pkg_id
		pkg_id="$(get_value "${PKG}_ID")"
		if [ -z "$pkg_id" ]; then
			eval ${PKG}_ID=\"$GAME_ID\"
			export ${PKG?}_ID
			pkg_id="$GAME_ID"
		fi

		# Get package architecture
		local pkg_architecture
		set_architecture "$PKG"

		# Set $PKG_PATH
		if [ "$OPTION_PACKAGE" = 'arch' ] && [ "$(get_value "${PKG}_ARCH")" = '32' ]; then
			pkg_id="lib32-$pkg_id"
		fi
		get_package_version
		eval ${PKG}_PATH=\"$PLAYIT_WORKDIR/${pkg_id}_${PKG_VERSION}_${pkg_architecture}\"
	else
		eval ${PKG}_PATH=/
	fi
	export ${PKG?}_PATH
}

# display an error if set_temp_directories() is called before setting $ARCHIVE_SIZE
# USAGE: set_temp_directories_error_no_size
# NEEDED VARS: (LANG)
# CALLS: print_error
# CALLED BY: set_temp_directories
set_temp_directories_error_no_size() {
	print_error
	case "${LANG%_*}" in
		('fr')
			string='$ARCHIVE_SIZE doit être défini avant tout appel à set_temp_directories().\n'
		;;
		('en'|*)
			string='$ARCHIVE_SIZE must be set before any call to set_temp_directories().\n'
		;;
	esac
	printf "$string"
	return 1
}

# display an error if there is not enough free space to work in any of the tested directories
# USAGE: set_temp_directories_error_not_enough_space
# NEEDED VARS: (LANG)
# CALLS: print_error
# CALLED BY: set_temp_directories
set_temp_directories_error_not_enough_space() {
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='Il n’y a pas assez d’espace libre dans les différents répertoires testés :\n'
		;;
		('en'|*)
			string='There is not enough free space in the tested directories:\n'
		;;
	esac
	printf "$string"
	if [ $OPTION_PACKAGE == raw ]; then
		echo "$OPTION_PREFIX"
	else
		echo -e "$XDG_RUNTIME_DIR"\\n"$(get_tmp_dir)"\\n"$XDG_CACHE_HOME"\\n"$PWD"
	fi
	return 1
}

