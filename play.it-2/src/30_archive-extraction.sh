# extract data from given archive
# USAGE: extract_data_from $archive[…]
# NEEDED_VARS: (ARCHIVE) (ARCHIVE_PASSWD) (ARCHIVE_TYPE) (LANG) (PLAYIT_WORKDIR)
# CALLS: liberror extract_7z extract_data_from_print
extract_data_from() {
	[ "$PLAYIT_WORKDIR" ] || return 1
	[ "$ARCHIVE" ] || return 1
	local file
	for file in "$@"; do
		extract_data_from_print "$(basename "$file")"

		local destination
		destination="$PLAYIT_WORKDIR/gamedata"
		mkdir --parents "$destination"
		if [ "$DRY_RUN" = '1' ]; then
			printf '\n'
			return 0
		fi
		local archive_type
		archive_type="$(get_value "${ARCHIVE}_TYPE")"
		case "$archive_type" in
			('7z')
				extract_7z "$file" "$destination"
			;;
			('cabinet')
				cabextract -L -d "$destination" -q "$file"
			;;
			('debian')
				dpkg-deb --extract "$file" "$destination"
			;;
			('innosetup'*)
				archive_extraction_innosetup "$archive_type" "$file" "$destination"
			;;
			('msi')
				msiextract --directory "$destination" "$file" 1>/dev/null 2>&1
				tolower "$destination"
			;;
			('mojosetup'|'iso')
				bsdtar --directory "$destination" --extract --file "$file"
				set_standard_permissions "$destination"
			;;
			('nix_stage1')
				local header_length
				local input_blocksize
				header_length="$(grep --text 'offset=.*head.*wc' "$file" | awk '{print $3}' | head --lines=1)"
				input_blocksize=$(head --lines="$header_length" "$file" | wc --bytes | tr --delete ' ')
				dd if="$file" ibs=$input_blocksize skip=1 obs=1024 conv=sync 2>/dev/null | gunzip --stdout | tar --extract --file - --directory "$destination"
			;;
			('nix_stage2')
				tar --extract --xz --file "$file" --directory "$destination"
			;;
			('rar'|'nullsoft-installer')
				# compute archive password from GOG id
				if [ -z "$ARCHIVE_PASSWD" ] && [ -n "$(get_value "${ARCHIVE}_GOGID")" ]; then
					ARCHIVE_PASSWD="$(printf '%s' "$(get_value "${ARCHIVE}_GOGID")" | md5sum | cut -d' ' -f1)"
				fi
				if [ -n "$ARCHIVE_PASSWD" ]; then
					UNAR_OPTIONS="-password $ARCHIVE_PASSWD"
				fi
				unar -no-directory -output-directory "$destination" $UNAR_OPTIONS "$file" 1>/dev/null
			;;
			('tar'|'tar.gz')
				tar --extract --file "$file" --directory "$destination"
			;;
			('zip')
				archive_extract_with_unzip "$file" "$destination"
			;;
			('zip_unclean'|'mojosetup_unzip')
				set +o errexit
				unzip -d "$destination" "$file" 1>/dev/null 2>&1
				set -o errexit
				set_standard_permissions "$destination"
			;;
			(*)
				liberror 'ARCHIVE_TYPE' 'extract_data_from'
			;;
		esac

		if [ "${archive_type#innosetup}" = "$archive_type" ]; then
			print_ok
		fi
	done
}

# print data extraction message
# USAGE: extract_data_from_print $file
# NEEDED VARS: (LANG)
# CALLED BY: extract_data_from
extract_data_from_print() {
	case "${LANG%_*}" in
		('fr')
			string='Extraction des données de %s'
		;;
		('en'|*)
			string='Extracting data from %s'
		;;
	esac
	printf "$string" "$1"
}

# extract data from InnoSetup archive
# USAGE: archive_extraction_innosetup $archive_type $archive $destination
# CALLS: archive_extraction_innosetup_error_version
archive_extraction_innosetup() {
	local archive
	local archive_type
	local destination
	local options
	archive_type="$1"
	archive="$2"
	destination="$3"
	options='--progress=1 --silent'
	if [ -n "${archive_type%%*_nolowercase}" ]; then
		options="$options --lowercase"
	fi
	if ( innoextract --list --silent "$archive" 2>&1 1>/dev/null |\
		head --lines=1 |\
		grep --ignore-case 'unexpected setup data version' 1>/dev/null )
	then
		archive_extraction_innosetup_error_version "$archive"
	fi
	printf '\n'
	innoextract $options --extract --output-dir "$destination" "$file" 2>/dev/null
}

# print error if available version of innoextract is too low
# USAGE: archive_extraction_innosetup_error_version $archive
# CALLED BY: archive_extraction_innosetup
archive_extraction_innosetup_error_version() {
	local archive
	archive="$1"
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='La version de innoextract disponible sur ce système est trop ancienne pour extraire les données de l’archive suivante :'
		;;
		('en'|*)
			string='Available innoextract version is too old to extract data from the following archive:'
		;;
	esac
	printf "$string %s\\n" "$archive"
	exit 1
}

# extract data using unzip
# USAGE: archive_extract_with_unzip $archive $destination
archive_extract_with_unzip() {
	local archive
	local destination
	local files_list
	archive="$1"
	destination="$2"
	set -f
	files_list="$(archive_get_files_to_extract "$archive" | sed 'p;/^.+$/s|$|/*|')"
	set +o errexit
	# shellcheck disable=SC2046
	(
		IFS='
'
		unzip -d "$destination" "$archive" $files_list 1>/dev/null 2>/dev/null
	)
	local status="$?"
	set -o errexit
	set +f
	[ "$status" -eq 0 ] || [ "$status" -eq 11 ] || return "$status"
}

# Outputs all files that need to be extracted
# USAGE: archive_get_files_to_extract
# CALLS: archive_concat_needed_files_with_path
archive_get_files_to_extract() {
	[ $version_major_target -lt 2 ] || [ $version_minor_target -lt 12 ] && return 0
	for package in $PACKAGES_LIST; do
		PKG="${package#PKG_}"
		archive_concat_needed_files_with_path "GAME_$PKG" "DOC_$PKG"
		for i in $(seq 0 9); do
			archive_concat_needed_files_with_path "GAME${i}_$PKG" "DOC${i}_$PKG"
		done
	done
	# shellcheck disable=2086
	printf '%s\n' $EXTRA_ARCHIVE_FILES
}

# Adds path prefix for files in ARCHIVE_*_FILES
# USAGE: archive_concat_needed_files_with_path $specifier …
# CALLED BY: archive_get_files_to_extract
archive_concat_needed_files_with_path() {
	for specifier in "$@"; do
		use_archive_specific_value "ARCHIVE_${specifier}_FILES"
		use_archive_specific_value "ARCHIVE_${specifier}_PATH"
		for file in $(get_value "ARCHIVE_${specifier}_FILES"); do
			if [ "$(get_value "ARCHIVE_${specifier}_PATH")" != '.' ]; then
				printf '%s\n' "$(get_value "ARCHIVE_${specifier}_PATH")/$file"
			else
				printf '%s\n' "$file"
			fi
		done
	done
}
