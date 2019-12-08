# WINE - write application-specific variables
# USAGE: launcher_write_script_wine_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_wine_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	# compute application-specific variables values
	local application_exe
	local application_options
	use_package_specific_value "${application}_EXE"
	use_package_specific_value "${application}_OPTIONS"
	application_exe="$(get_value "${application}_EXE")"
	application_options="$(get_value "${application}_OPTIONS")"

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"

	EOF
	return 0
}

# WINE - write launcher script prefix initialization
# USAGE: launcher_write_script_wine_prefix_build $file
# NEEDED VARS: PKG APP_WINETRICKS APP_REGEDIT
# CALLED BY: launcher_write_build
launcher_write_script_wine_prefix_build() {
	local file
	file="$1"

	# compute WINE prefix architecture
	local architecture
	local winearch
	use_archive_specific_value "${PKG}_ARCH"
	architecture="$(get_value "${PKG}_ARCH")"
	case "$architecture" in
		('32') winearch='win32' ;;
		('64') winearch='win64' ;;
	esac

	# check which variant of wine to use
	local dependencies
	local use_staging
	use_archive_specific_value "${PKG}_DEPS"
	dependencies="$(get_value "${PKG}_DEPS")"
	case "$dependencies" in
		(*'wine-staging'*|*'wine32-staging'*|*'wine64-staging'*)
			use_staging=1
		;;
		(*'wine '*|*'wine32 '*|*'wine64 '*|*'wine'|*'wine32'|*'wine64')
			use_staging=0
		;;
	esac

	cat >> "$file" <<- EOF
	# Build user prefix

	WINEARCH='$winearch'
	EOF

	cat >> "$file" <<- 'EOF'
	WINEDEBUG='-all'
	WINEDLLOVERRIDES='winemenubuilder.exe,mscoree,mshtml=d'
	WINEPREFIX="$XDG_DATA_HOME/play.it/prefixes/$PREFIX_ID"
	# Work around WINE bug 41639
	FREETYPE_PROPERTIES="truetype:interpreter-version=35"

	PATH_PREFIX="$WINEPREFIX/drive_c/$GAME_ID"

	export WINEARCH WINEDEBUG WINEDLLOVERRIDES WINEPREFIX FREETYPE_PROPERTIES

	EOF

	if [ "$use_staging" = 1 ]; then
		cat >> "$file" <<- 'EOF'
		for command in wine-staging wine-any wine; do
		    if command -v "$command" >/dev/null; then
		        wine="$command"
			break
		    fi
		done
		for command in wineboot-staging wineboot-any wineboot; do
		    if command -v "$command" >/dev/null; then
		        wineboot="$command"
			break
		    fi
		done
		for command in wineserver-staging wineserver-any wineserver; do
		    if command -v "$command" >/dev/null; then
		        wineserver="$command"
			break
		    fi
		done
		EOF
	elif [ "$use_staging" = 0 ]; then
		cat >> "$file" <<- 'EOF'
		for command in wine-vanilla wine-stable wine-development wine; do
		    if command -v "$command" >/dev/null; then
		        wine="$command"
			break
		    fi
		done
		for command in wineboot-vanilla wineboot-stable wineboot-development wineboot; do
		    if command -v "$command" >/dev/null; then
		        wineboot="$command"
			break
		    fi
		done
		for command in wineserver-vanilla wineserver-stable wineserver-development wineserver; do
		    if command -v "$command" >/dev/null; then
		        wineserver="$command"
			break
		    fi
		done
		EOF
	fi
	if [ -n "$use_staging" ]; then
		cat >> "$file" <<- 'EOF'
		# winetricks variables
		export WINE="$wine"
		export WINESERVER="$wineserver"
		export WINEBOOT="$wineboot"
		EOF
	else # if wine wasn't found in dependencies, revert to old behavior
		cat >> "$file" <<- 'EOF'
		wine=wine
		wineboot=wineboot
		wineserver=wineserver
		EOF
	fi

	cat >> "$file" <<- 'EOF'

	if ! [ -e "$WINEPREFIX" ]; then
	    mkdir --parents "${WINEPREFIX%/*}"
	    # Use LANG=C to avoid localized directory names
	    LANG=C "$wineboot" --init 2>/dev/null
	EOF

	local version_major_target
	local version_minor_target
	version_major_target="${target_version%%.*}"
	version_minor_target=$(printf '%s' "$target_version" | cut --delimiter='.' --fields=2)
	if ! { [ $version_major_target -lt 2 ] || [ $version_minor_target -lt 8 ] ; }; then
		cat >> "$file" <<- 'EOF'
		    # Remove most links pointing outside of the WINE prefix
		    rm "$WINEPREFIX/dosdevices/z:"
		    find "$WINEPREFIX/drive_c/users/$(whoami)" -type l | while read directory; do
		        rm "$directory"
		        mkdir "$directory"
		    done
		EOF
	fi

	if [ "$APP_WINETRICKS" ]; then
		cat >> "$file" <<- EOF
		    winetricks $APP_WINETRICKS
		    sleep 1s
		EOF
	fi

	if [ "$APP_REGEDIT" ]; then
		cat >> "$file" <<- EOF
		    for reg_file in $APP_REGEDIT; do
		EOF
		cat >> "$file" <<- 'EOF'
		    (
		        cd "$WINEPREFIX/drive_c/"
		        cp "$PATH_GAME/$reg_file" .
		        reg_file_basename="${reg_file##*/}"
		        "$wine" regedit "$reg_file_basename"
		        rm "$reg_file_basename"
		    )
		    done
		EOF
	fi

	cat >> "$file" <<- 'EOF'
	fi
	EOF

	cat >> "$file" <<- 'EOF'
	for dir in "$PATH_PREFIX" "$PATH_CONFIG" "$PATH_DATA"; do
	    if [ ! -e "$dir" ]; then
	        mkdir --parents "$dir"
	    fi
	done
	(
	    cd "$PATH_GAME"
	    find . -type d | while read dir; do
	        if [ -h "$PATH_PREFIX/$dir" ]; then
	            rm "$PATH_PREFIX/$dir"
	        fi
	    done
	)
	cp --recursive --remove-destination --symbolic-link "$PATH_GAME"/* "$PATH_PREFIX"
	(
	    cd "$PATH_PREFIX"
	    find . -type l | while read link; do
	        if [ ! -e "$link" ]; then
	            rm "$link"
	        fi
	    done
	    find . -depth -type d | while read dir; do
	        if [ ! -e "$PATH_GAME/$dir" ]; then
	            rmdir --ignore-fail-on-non-empty "$dir"
	        fi
	    done
	)
	init_userdir_files "$PATH_CONFIG" "$CONFIG_FILES"
	init_userdir_files "$PATH_DATA" "$DATA_FILES"
	init_prefix_files "$PATH_CONFIG" "$CONFIG_FILES"
	init_prefix_files "$PATH_DATA" "$DATA_FILES"
	init_prefix_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# WINE - write launcher script for winecfg
# USAGE: launcher_write_script_wine_winecfg $application
# NEEDED VARS: GAME_ID
# CALLED BY: launcher_write_script_wine_winecfg
launcher_write_script_wine_winecfg() {
	local application
	application="$1"
	# shellcheck disable=SC2034
	APP_WINECFG_ID="${GAME_ID}_winecfg"
	# shellcheck disable=SC2034
	APP_WINECFG_TYPE='wine'
	# shellcheck disable=SC2034
	APP_WINECFG_EXE='winecfg'
	launcher_write_script 'APP_WINECFG'
	return 0
}

# WINE - run the game
# USAGE: launcher_write_script_wine_run $application $file
# CALLS: launcher_write_script_prerun launcher_write_script_postrun
# CALLED BY: launcher_write_script
launcher_write_script_wine_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

	launcher_write_script_prerun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	"$wine" "$APP_EXE" $APP_OPTIONS $@

	EOF

	launcher_write_script_postrun "$application" "$file"

	return 0
}
