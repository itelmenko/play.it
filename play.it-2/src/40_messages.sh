# display an error if a function is called without an argument
# USAGE: error_missing_argument $function
# CALLS: print_error
error_missing_argument() {
	local function
	function="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='La fonction "%s" ne peut pas être appelée sans argument.\n'
		;;
		('en'|*)
			string='"%s" function can not be called without an argument.\n'
		;;
	esac
	printf "$string" "$function"
	exit 1
}

# display an error if a function is called more than one argument
# USAGE: error_extra_arguments $function
# CALLS: print_error
error_extra_arguments() {
	local function
	function="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='La fonction "%s" ne peut pas être appelée avec plus d’un argument.\n'
		;;
		('en'|*)
			string='"%s" function can not be called with mor than one single argument.\n'
		;;
	esac
	printf "$string" "$function"
	exit 1
}

# display an error if function is called while $PKG is unset
# USAGE: error_no_pkg $function
# CALLS: print_error
error_no_pkg() {
	local function
	function="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='La fonction "%s" ne peut pas être appelée lorsque $PKG n’a pas de valeur définie.\n'
		;;
		('en'|*)
			string='"%s" function can not be called when $PKG is not set.\n'
		;;
	esac
	printf "$string" "$function"
	exit 1
}

# display an error if a file is expected and something else has been given
# USAGE: error_not_a_file $param
# CALLS: print_error
error_not_a_file() {
	if [ $# -lt 1 ]; then
		error_missing_argument 'error_not_a_file'
	fi
	if [ $# -gt 1 ]; then
		error_extra_arguments 'error_not_a_file'
	fi
	local param
	param="$1"
	print_error
	case "${LANG%_*}" in
		('fr')
			string='"%s" nʼest pas un fichier valide.\n'
		;;
		('en'|*)
			string='"%s" is not a valid file.\n'
		;;
	esac
	printf "$string" "$param"
	exit 1
}

# display an error when an unknown application type is used
# USAGE: error_unknown_application_type $app_type
# CALLS: print_error
error_unknown_application_type() {
	local application_type
	application_type="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			string='Le type dʼapplication "%s" est inconnu.\n'
			string="$string"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			string='"%s" application type is unknown.\n'
			string="$string"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	printf "$string" "$application_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	exit 1
}


# display an error if the path isn't a directory
# USAGE: error_not_a_directory $directory
# CALLS: print_error
error_not_a_directory () {
	local directory
	directory="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='"%s" n’est pas un répertoire.'
		;;
		('en'|*)
			# shellcheck disable=SC1112
			string='"%s" isn’t a directory'
		;;
	esac
	# shellcheck disable=SC2059
	printf "$string" "$directory"
	exit 1
}
