# print installation instructions for Gentoo Linux
# USAGE: print_instructions_gentoo $pkg[…]
print_instructions_gentoo() {
	local pkg_path
	local str_format
	printf 'quickunpkg --'
	for pkg in "$@"; do
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${PACKAGES_LIST##*$pkg*}" ]; then
			skipping_pkg_warning 'print_instructions_gentoo' "$pkg"
			return 0
		fi
		pkg_path="$(get_value "${pkg}_PKG")"
		if [ -z "${pkg_path##* *}" ]; then
			str_format=' "%s"'
		else
			str_format=' %s'
		fi
		printf "$str_format" "$pkg_path"
	done
	printf ' # %s\n' 'https://ptpb.pw/W1m8'
}

