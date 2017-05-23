# alias calling write_bin() and write_desktop()
# USAGE: write_launcher $app[…]
# CALLS: write_bin write_dekstop
write_launcher() {
	write_bin $@
	write_desktop $@
}

# write launcher script
# USAGE: write_bin $app
# NEEDED VARS: $PKG $APP_ID $APP_TYPE $PATH_BIN $APP_EXE $APP_OPTIONS $APP_LIBS
#  $APP_PRERUN
# CALLS: liberror write_bin_set_vars write_bin_set_exe write_bin_set_prefix
#  write_bin_build_userdirs write_bin_build_prefix write_bin_run
write_bin() {
	PKG_PATH="$(eval echo \$${PKG}_PATH)"
	local app
	for app in $@; do
		testvar "$app" 'APP' || liberror 'app' 'write_bin'

		# Get app-specific variables
		local app_id="$(eval echo \$${app}_ID)"
		local app_type="$(eval echo \$${app}_TYPE)"
		[ "$app_id" ] || app_id="$GAME_ID"
		if [ "$app_type" != 'scummvm' ]; then
			local app_exe="$(eval echo \$${app}_EXE)"
			local app_libs="$(eval echo \$${app}_LIBS)"
			local app_options="$(eval echo \$${app}_OPTIONS)"
			local app_prerun="$(eval echo \$${app}_PRERUN)"
			local app_postrun="$(eval echo \$${app}_POSTRUN)"
			[ "$app_exe" ]  || app_exe="$(eval echo \"\$${app}_EXE_${PKG#PKG_}\")"
			[ "$app_libs" ] || app_libs="$(eval echo \"\$${app}_LIBS_${PKG#PKG_}\")"
			if [ "$app_type" = 'native' ]; then
				chmod +x "${PKG_PATH}${PATH_GAME}/$app_exe"
			fi
		fi

		# Write winecfg launcher for WINE games
		if [ "$app_type" = 'wine' ]; then
			write_bin_winecfg
		fi

		local file="${PKG_PATH}${PATH_BIN}/$app_id"
		mkdir --parents "${file%/*}"

		# Write launcher headers
		cat > "$file" <<- EOF
		#!/bin/sh
		# script generated by ./play.it $library_version - http://wiki.dotslashplay.it/
		set -o errexit

		EOF

		# Write launcher
		if [ "$app_type" = 'scummvm' ]; then
			write_bin_set_scummvm
		else
			if [ "$app_id" != "${GAME_ID}_winecfg" ]; then
				write_bin_set_exe
			fi
			write_bin_set
			write_bin_build
		fi
		write_bin_run
		sed -i 's/  /\t/g' "$file"
		chmod 755 "$file"

	done
}

# write launcher script - set target binary/script to run the game
# USAGE: write_bin_set_exe
# CALLED BY: write_bin
write_bin_set_exe() {
	cat >> "$file" <<- EOF

	# Set executable file

	APP_EXE='$app_exe'
	APP_OPTIONS='$app_options'
	export LD_LIBRARY_PATH="$app_libs:\$LD_LIBRARY_PATH"
	EOF
}

# write launcher script - set common vars
# USAGE: write_bin_set_vars
# CALLED BY: write_bin
write_bin_set() {
	cat >> "$file" <<- EOF

	# Set game-specific variables

	GAME_ID='$GAME_ID'
	PATH_GAME='$PATH_GAME'

	CACHE_DIRS='$CACHE_DIRS'
	CACHE_FILES='$CACHE_FILES'

	CONFIG_DIRS='$CONFIG_DIRS'
	CONFIG_FILES='$CONFIG_FILES'

	DATA_DIRS='$DATA_DIRS'
	DATA_FILES='$DATA_FILES'

	EOF
	cat >> "$file" <<- 'EOF'
	# Set prefix name

	[ "$PREFIX_ID" ] || PREFIX_ID="$GAME_ID"

	# Set prefix-specific variables

	[ "$XDG_CACHE_HOME" ] || XDG_CACHE_HOME="$HOME/.cache"
	[ "$XDG_CONFIG_HOME" ] || XDG_CONFIG_HOME="$HOME/.config"
	[ "$XDG_DATA_HOME" ] || XDG_DATA_HOME="$HOME/.local/share"

	PATH_CACHE="$XDG_CACHE_HOME/$PREFIX_ID"
	PATH_CONFIG="$XDG_CONFIG_HOME/$PREFIX_ID"
	PATH_DATA="$XDG_DATA_HOME/games/$PREFIX_ID"
	EOF
	if [ "$app_type" = 'wine' ]; then
		write_bin_set_wine
	else
		cat >> "$file" <<- 'EOF'
		PATH_PREFIX="$XDG_DATA_HOME/play.it/prefixes/$PREFIX_ID"
		EOF
	fi
	cat >> "$file" <<- 'EOF'

	# Set ./play.it functions

	clean_userdir() {
	  cd "$PATH_PREFIX"
	  for file in $2; do
	    if [ -f "$file" ] && [ ! -f "$1/$file" ]; then
	      cp --parents "$file" "$1"
	      rm "$file"
	      ln --symbolic "$(readlink -e "$1/$file")" "$file"
	    fi
	  done
	}

	init_prefix_dirs() {
	  (
	    cd "$1"
	    for dir in $2; do
	      rm --force --recursive "$PATH_PREFIX/$dir"
	      mkdir --parents "$PATH_PREFIX/${dir%/*}"
	      ln --symbolic "$(readlink -e "$dir")" "$PATH_PREFIX/$dir"
	    done
	  )
	}

	init_prefix_files() {
	  (
	    cd "$1"
	    find . -type f | while read file; do
	      local file_prefix="$(readlink -e "$PATH_PREFIX/$file")"
	      local file_real="$(readlink -e "$file")"
	      if [ "$file_real" != "$file_prefix" ]; then
	        rm --force "$PATH_PREFIX/$file"
	        mkdir --parents "$PATH_PREFIX/${file%/*}"
	        ln --symbolic "$file_real" "$PATH_PREFIX/$file"
	      fi
	    done
	  )
	}

	init_userdir_dirs() {
	  (
	    cd "$PATH_GAME"
	    for dir in $2; do
	      if [ ! -e "$1/$dir" ] && [ -e "$dir" ]; then
	        cp --parents --recursive "$dir" "$1"
	      else
	        mkdir --parents "$1/$dir"
	      fi
	    done
	  )
	}

	init_userdir_files() {
	  (
	    cd "$PATH_GAME"
	    for file in $2; do
	      if [ ! -e "$1/$file" ] && [ -e "$file" ]; then
	        cp --parents "$file" "$1"
	      fi
	    done
	  )
	}
		EOF
}

# write launcher script - build game prefix
# USAGE: write_bin_build
write_bin_build() {
	cat >> "$file" <<- 'EOF'

	# Build user-writable directories

	if [ ! -e "$PATH_CACHE" ]; then
	  mkdir --parents "$PATH_CACHE"
	  init_userdir_dirs "$PATH_CACHE" "$CACHE_DIRS"
	  init_userdir_files "$PATH_CACHE" "$CACHE_FILES"
	fi

	if [ ! -e "$PATH_CONFIG" ]; then
	  mkdir --parents "$PATH_CONFIG"
	  init_userdir_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	  init_userdir_files "$PATH_CONFIG" "$CONFIG_FILES"
	fi

	if [ ! -e "$PATH_DATA" ]; then
	  mkdir --parents "$PATH_DATA"
	  init_userdir_dirs "$PATH_DATA" "$DATA_DIRS"
	  init_userdir_files "$PATH_DATA" "$DATA_FILES"
	fi

	# Build prefix

	EOF

	if [ "$app_type" = 'wine' ]; then
		write_bin_build_wine
	fi
	cat >> "$file" <<- 'EOF'
	if [ ! -e "$PATH_PREFIX" ]; then
	  mkdir --parents "$PATH_PREFIX"
	  cp --force --recursive --symbolic-link --update "$PATH_GAME"/* "$PATH_PREFIX"
	fi
	init_prefix_files "$PATH_CACHE"
	init_prefix_files "$PATH_CONFIG"
	init_prefix_files "$PATH_DATA"
	init_prefix_dirs "$PATH_CACHE" "$CACHE_DIRS"
	init_prefix_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
	EOF
}

# write launcher script - run the game, then clean the user-writable directories
# USAGE: write_bin_run
# CALLS: write_bin_run_dosbox write_bin_run_native write_bin_run_scummvm
# 	write_bin_run_wine
write_bin_run() {
	cat >> "$file" <<- EOF

	# Run the game

	EOF

	case $app_type in
		('dosbox')
			write_bin_run_dosbox
		;;
		('native')
			write_bin_run_native
		;;
		('scummvm')
			write_bin_run_scummvm
		;;
		('wine')
			write_bin_run_wine
		;;
	esac

	if [ $app_type != 'scummvm' ]; then
		cat >> "$file" <<- 'EOF'
		clean_userdir "$PATH_CACHE" "$CACHE_FILES"
		clean_userdir "$PATH_CONFIG" "$CONFIG_FILES"
		clean_userdir "$PATH_DATA" "$DATA_FILES"
		EOF
	fi

	cat >> "$file" <<- EOF

	exit 0
	EOF
}

# write menu entry
# USAGE: write_desktop $app
# NEEDED VARS: $app_TYPE, $app_ID, $app_NAME, $app_CAT, PKG_PATH, PATH_DESK
# CALLS: liberror
write_desktop() {
	local app
	for app in $@; do
		testvar "$app" 'APP' || liberror 'app' 'write_desktop'
		local type="$(eval echo \$${app}_TYPE)"
		if [ "$winecfg_desktop" != 'done' ] && [ "$type" = 'wine' ]; then
			winecfg_desktop='done'
			write_desktop_winecfg
		fi
		local id="$(eval echo \$${app}_ID)"
		if [ -z "$id" ]; then
			id="$GAME_ID"
		fi
		local name="$(eval echo \$${app}_NAME)"
		if [ -z "$name" ]; then
			name="$GAME_NAME"
		fi
		local cat="$(eval echo \$${app}_CAT)"
		if [ -z "$cat" ]; then
			cat='Game'
		fi
		local target="${PKG_PATH}${PATH_DESK}/${id}.desktop"
		mkdir --parents "${target%/*}"
		cat > "${target}" <<- EOF
		[Desktop Entry]
		Version=1.0
		Type=Application
		Name=$name
		Icon=$id
		Exec=$id
		Categories=$cat
		EOF
	done
}

# write winecfg launcher script
# USAGE: write_desktop_winecfg
# NEEDED VARS: GAME_ID
# CALLS: write_desktop
write_desktop_winecfg() {
	APP_WINECFG_ID="${GAME_ID}_winecfg"
	APP_WINECFG_NAME="$GAME_NAME - WINE configuration"
	APP_WINECFG_CAT='Settings'
	write_desktop 'APP_WINECFG'
	sed --in-place 's/Icon=.\+/Icon=winecfg/' "${PKG_PATH}${PATH_DESK}/${APP_WINECFG_ID}.desktop"
}
