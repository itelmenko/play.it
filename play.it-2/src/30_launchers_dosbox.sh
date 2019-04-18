# DOSBox - write application-specific variables
# USAGE: launcher_write_script_dosbox_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_dosbox_application_variables() {
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

# DOSBox - generate the play.it config file if missing
# USAGE: launcher_write_script_dosbox_generate_config $file
# NEEDED_VARS: GAME_IMAGE GAME_IMAGE_TYPE PACKAGES_LIST PATH_GAME
# CALLED BY: launcher_write_script
launcher_write_script_dosbox_generate_config() {
	# parse arguments
	local file
	file="$1"

	cat >> "$file" <<- 'EOFEOF'
	# Generate the play.it config file if missing
	[ -d "$HOME/.dosbox" ] || mkdir "$HOME/.dosbox"
	if [ ! -f "$HOME/.dosbox/play.it.conf" ]; then
	cat >> "$HOME/.dosbox/play.it.conf" <<- 'EOF'
	[sdl]
	output=overlay
	#fullscreen=true # enable this if you want fullscreen by default
	fullresolution=desktop # makes dosbox use the right screen resolution in fullscreen: BROKEN FOR >1 SCREEN, use your smallest used resolution instead
	EOF
	fi

	EOFEOF
}
# DOSBox - run the game
# USAGE: launcher_write_script_dosbox_run $application $file
# NEEDED_VARS: GAME_IMAGE GAME_IMAGE_TYPE PACKAGES_LIST PATH_GAME
# CALLS: launcher_write_script_prerun launcher_write_script_postrun
# CALLED BY: launcher_write_script
launcher_write_script_dosbox_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"
	dosbox -userconf -conf ~/.dosbox/play.it.conf -conf dosbox.conf -c "mount c .
	c:
	EOF

	# mount CD image file
	if [ "$GAME_IMAGE" ]; then
		case "$GAME_IMAGE_TYPE" in
			('cdrom')
				local image
				local package
				local package_path
				for package in $PACKAGES_LIST; do
					package_path="$(get_value "${pkg}_PATH")"
					if [ -e "${package_path}$PATH_GAME/$GAME_IMAGE" ]; then
						image="${package_path}$PATH_GAME/$GAME_IMAGE"
						break;
					fi
				done
				if [ -d "$image" ]; then
					cat >> "$file" <<- EOF
					mount d $GAME_IMAGE -t cdrom
					EOF
				else
					cat >> "$file" <<- EOF
					imgmount d $GAME_IMAGE -t cdrom
					EOF
				fi
			;;
			('iso'|*)
				cat >> "$file" <<- EOF
				imgmount d $GAME_IMAGE -t iso -fs iso
				EOF
			;;
		esac
	fi

	launcher_write_script_prerun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	$APP_EXE $APP_OPTIONS $@
	EOF

	launcher_write_script_postrun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	exit"

	EOF
	return 0
}

