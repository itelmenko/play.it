# display script usage
# USAGE: help
# NEEDED VARS: (LANG)
# CALLS: help_checksum help_compression help_prefix help_package help_dryrun help_skipfreespacecheck
help() {
	local format
	local string
	local string_archive
	case "${LANG%_*}" in
		('fr')
			string='Utilisation :'
			# shellcheck disable=SC1112
			string_archive='Ce script reconnaît l’archive suivante :'
			string_archives='Ce script reconnaît les archives suivantes :'
		;;
		('en'|*)
			string='Usage:'
			string_archive='This script can work on the following archive:'
			string_archives='This script can work on the following archives:'
		;;
	esac
	printf '\n'
	if [ "${0##*/}" = 'play.it' ]; then
		format='%s %s ARCHIVE [OPTION]…\n\n'
	else
		format='%s %s [OPTION]… [ARCHIVE]\n\n'
	fi
	printf "$format" "$string" "${0##*/}"
	
	printf 'OPTIONS\n\n'
	help_architecture
	printf '\n'
	help_checksum
	printf '\n'
	help_compression
	printf '\n'
	help_prefix
	printf '\n'
	help_package
	printf '\n'
	help_dryrun
	printf '\n'
	help_skipfreespacecheck
	printf '\n'

	printf 'ARCHIVE\n\n'
	archives_get_list
	if [ -n "${ARCHIVES_LIST##* *}" ]; then
		printf '%s\n' "$string_archive"
	else
		printf '%s\n' "$string_archives"
	fi
	for archive in $ARCHIVES_LIST; do
		printf '%s\n' "$(get_value "$archive")"
	done
	printf '\n'
}

# display --architecture option usage
# USAGE: help_architecture
# NEEDED VARS: (LANG)
# CALLED BY: help
help_architecture() {
	local string
	local string_all
	local string_32
	local string_64
	local string_auto
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='Choix de l’architecture à construire'
			string_all='toutes les architectures disponibles (méthode par défaut)'
			string_32='paquets 32-bit seulement'
			string_64='paquets 64-bit seulement'
			# shellcheck disable=SC1112
			string_auto='paquets pour l’architecture du système courant uniquement'
		;;
		('en'|*)
			string='Target architecture choice'
			string_all='all available architectures (default method)'
			string_32='32-bit packages only'
			string_64='64-bit packages only'
			string_auto='packages for current system architecture only'
		;;
	esac
	printf -- '--architecture=all|32|64|auto\n'
	printf -- '--architecture all|32|64|auto\n\n'
	printf '\t%s\n\n' "$string"
	printf '\tall\t%s\n' "$string_all"
	printf '\t32\t%s\n' "$string_32"
	printf '\t64\t%s\n' "$string_64"
	printf '\tauto\t%s\n' "$string_auto"
}

# display --checksum option usage
# USAGE: help_checksum
# NEEDED VARS: (LANG)
# CALLED BY: help
help_checksum() {
	local string
	local string_md5
	local string_none
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='Choix de la méthode de vérification d’intégrité de l’archive'
			string_md5='vérification via md5sum (méthode par défaut)'
			string_none='pas de vérification'
		;;
		('en'|*)
			string='Archive integrity verification method choice'
			string_md5='md5sum verification (default method)'
			string_none='no verification'
		;;
	esac
	printf -- '--checksum=md5|none\n'
	printf -- '--checksum md5|none\n\n'
	printf '\t%s\n\n' "$string"
	printf '\tmd5\t%s\n' "$string_md5"
	printf '\tnone\t%s\n' "$string_none"
}

# display --compression option usage
# USAGE: help_compression
# NEEDED VARS: (LANG)
# CALLED BY: help
help_compression() {
	local string
	local string_none
	local string_gzip
	local string_xz
	case "${LANG%_*}" in
		('fr')
			string='Choix de la méthode de compression des paquets générés (certaines options peuvent ne pas être disponible suivant le format de paquet choisi)'
			string_none='pas de compression (méthode par défaut)'
			string_gzip='compression gzip (rapide)'
			string_xz='compression xz (plus lent mais plus efficace que gzip)'
			string_bzip2='compression bzip2 (plus rapide que xz pour la compression, mais moins efficace)'
			string_zstd='compression zstd (un peu moins efficace que xz mais plus rapide à la décompression)'
			string_lz4='compression lz4 (le plus rapide, mais aussi le plus lourd)'
			string_lzip='compression lzip (similaire à xz)'
			string_lzop='compression lzop (plus lent que lz4 pour la décompression mais plus efficace)'
		;;
		('en'|*)
			string='Generated packages compression method choice (some options may not be available depending on the chosen package format)'
			string_none='no compression (default method)'
			string_gzip='gzip compression (fast)'
			string_xz='xz compression (slower but more efficient than gzip)'
			string_bzip2='bzip2 compression (faster than xz for compression but less efficient)'
			string_zstd='zstd compression (a little bit less efficient as xz but faster at decompression)'
			string_lz4='lz4 compression (fastest, but biggest files)'
			string_lzip='lzip compression (similar to xz)'
			string_lzop='lzop compression (slower than lz4 at decompression but more efficient)'
		;;
	esac
	printf -- '--compression=none|gzip|xz|bzip2|zstd|lz4|lzip|lzop\n'
	printf -- '--compression none|gzip|xz|bzip2|zstd|lz4|lzip|lzop\n\n'
	printf '\t%s\n\n' "$string"
	printf '\tnone\t%s\n' "$string_none"
	printf '\tgzip\t%s\n' "$string_gzip"
	printf '\txz\t%s\n' "$string_xz"
	printf '\tbzip2\t%s\n' "$string_bzip2"
	printf '\tzstd\t%s\n' "$string_zstd"
	printf '\tlz4\t%s\n' "$string_lz4"
	printf '\tlzip\t%s\n' "$string_lzip"
	printf '\tlzop\t%s\n' "$string_lzop"
}

# display --prefix option usage
# USAGE: help_prefix
# NEEDED VARS: (LANG)
# CALLED BY: help
help_prefix() {
	local string
	local string_absolute
	local string_default
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='Choix du chemin d’installation du jeu'
			string_absolute='Cette option accepte uniquement un chemin absolu.'
			string_default='chemin par défaut :'
		;;
		('en'|*)
			string='Game installation path choice'
			string_absolute='This option accepts an absolute path only.'
			string_default='default path:'
		;;
	esac
	printf -- '--prefix=$path\n'
	printf -- '--prefix $path\n\n'
	printf '\t%s\n\n' "$string"
	printf '\t%s\n' "$string_absolute"
	printf '\t%s /usr/local\n' "$string_default"
}

# display --package option usage
# USAGE: help_package
# NEEDED VARS: (LANG)
# CALLED BY: help
help_package() {
	local string
	local string_default
	local string_arch
	local string_deb
	local string_gentoo
	case "${LANG%_*}" in
		('fr')
			string='Choix du type de paquet à construire'
			string_default='(type par défaut)'
			string_arch='paquet .pkg.tar (Arch Linux)'
			string_deb='paquet .deb (Debian, Ubuntu)'
			string_gentoo='paquet .tbz2 (Gentoo)'
		;;
		('en'|*)
			string='Generated package Type choice'
			string_default='(default type)'
			string_arch='.pkg.tar package (Arch Linux)'
			string_deb='.deb package (Debian, Ubuntu)'
			string_gentoo='.tbz2 package (Gentoo)'
		;;
	esac
	printf -- '--package=arch|deb|gentoo\n'
	printf -- '--package arch|deb|gentoo\n\n'
	printf '\t%s\n\n' "$string"
	printf '\tarch\t%s' "$string_arch"
	[ "$DEFAULT_OPTION_PACKAGE" = 'arch' ] && printf ' %s\n' "$string_default" || printf '\n'
	printf '\tdeb\t%s' "$string_deb"
	[ "$DEFAULT_OPTION_PACKAGE" = 'deb' ] && printf ' %s\n' "$string_default" || printf '\n'
	printf '\tgentoo\t%s' "$string_gentoo"
	[ "$DEFAULT_OPTION_PACKAGE" = 'gentoo' ] && printf ' %s\n' "$string_default" || printf '\n'
}

# display --dry-run option usage
# USAGE: help_dryrun
# NEEDED VARS: (LANG)
# CALLED BY: help
help_dryrun() {
	local string
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='Effectue des tests de syntaxe mais n’extrait pas de données et ne construit pas de paquets.'
		;;
		('en'|*)
			string='Run syntax checks but do not extract data nor build packages.'
		;;
	esac
	printf -- '--dry-run\n\n'
	printf '\t%s\n\n' "$string"
}

# display --skip-free-space-check option usage
# USAGE: help_skipfreespacecheck
# NEEDED VARS: (LANG)
# CALLED BY: help
help_skipfreespacecheck() {
	local string
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='Ne teste pas l’espace libre disponible. Les répertoires temporaires seront créés sous $TMPDIR, ou /tmp par défaut.'
		;;
		('en'|*)
			string='Do not check for free space. Temporary directories are created under $TMPDIR, or /tmp by default.'
		;;
	esac
	printf -- '--skip-free-space-check\n\n'
	printf '\t%s\n\n' "$string"
}

