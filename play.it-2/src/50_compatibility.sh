# Keep compatibility with 2.11.2 and older

icons_linking_postinst() {
	[ "$DRY_RUN" = '1' ] && return 0
	case "$OPTION_PACKAGE" in
		('arch')
			local app
			local file
			local icon
			local list
			local name
			local path
			local path_icon
			local path_pkg
			local version_major_target
			local version_minor_target
			# shellcheck disable=SC2154
			version_major_target="${target_version%%.*}"
			# shellcheck disable=SC2154
			version_minor_target=$(printf '%s' "$target_version" | cut --delimiter='.' --fields=2)
			path_pkg="$(get_value "${PKG}_PATH")"
			[ -n "$path_pkg" ] || missing_pkg_error 'icons_linking_postinst' "$PKG"
			path="${path_pkg}${PATH_GAME}"
			for app in "$@"; do
				list="$(get_value "${app}_ICONS_LIST")"
				[ "$list" ] || list="${app}_ICON"
				name="$(get_value "${app}_ID")"
				[ "$name" ] || name="$GAME_ID"
				for icon in $list; do
					file="$(get_value "$icon")"
					if [ $version_major_target -lt 2 ] || [ $version_minor_target -lt 8 ]; then
						# ensure compatibility with scripts targeting pre-2.8 library
						if [ -e "$path/$file" ] || [ -e "$path"/$file ]; then
							icon_get_resolution_from_file "$path/$file"
						else
							icon_get_resolution_from_file "${PKG_DATA_PATH}${PATH_GAME}/$file"
						fi
					else
						icon_get_resolution_from_file "$path/$file"
					fi
					path_icon="$PATH_ICON_BASE/$resolution/apps"
					cat >> "$prerm" <<- EOF
					if [ -e "$path_icon/$name.png" ]; then
					rm "$path_icon/$name.png"
					rmdir --parents --ignore-fail-on-non-empty "$path_icon"
					fi
					EOF
				done
			done
		;;
	esac
	icons_get_from_package "$@"
}

# Keep compatibility with 2.10 and older

write_bin() {
	local application
	for application in "$@"; do
		launcher_write_script "$application"
	done
}

write_desktop() {
	local application
	for application in "$@"; do
		launcher_write_desktop "$application"
	done
}

write_desktop_winecfg() {
	launcher_write_desktop 'APP_WINECFG'
}

write_launcher() {
	launchers_write "$@"
}

# Keep compatibility with 2.7 and older

extract_and_sort_icons_from() {
	icons_get_from_package "$@"
}

extract_icon_from() {
	local destination
	local file
	destination="$PLAYIT_WORKDIR/icons"
	mkdir --parents "$destination"
	for file in "$@"; do
		extension="${file##*.}"
		case "$extension" in
			('exe')
				icon_extract_ico_from_exe "$file" "$destination"
			;;
			(*)
				icon_extract_png_from_file "$file" "$destination"
			;;
		esac
	done
}

get_icon_from_temp_dir() {
	icons_get_from_workdir "$@"
}

move_icons_to() {
	icons_move_to "$@"
}

postinst_icons_linking() {
	icons_linking_postinst "$@"
}

# Keep compatibility with 2.6.0 and older

set_archive() {
	archive_set "$@"
}

set_archive_error_not_found() {
	archive_set_error_not_found "$@"
}

