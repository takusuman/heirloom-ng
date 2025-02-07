# Copyright (C) 2024: Luiz Antônio Rangel (takusuman)
# SPDX-Licence-Identifier: Zlib
#
# Honorable mention to Nosomy for help given in the
# AWK section of this script.

fGlob=false
main() {
	while getopts ':f' c; do
		case "$c" in
			f) fGlob=true
				break ;;
			\?) # ignore
				break ;;
		esac
	done
	shift `expr $OPTIND - 1`

	case "`echo "x$@"`" in
		'x') # stdin
			while read -r l; do
				# An "arrayoid", so we can
				# cache std.in. into "argv".
				set -- "$@" "$l"
			done
			break ;;
		*) # argv
			break ;;
	esac

	# Set echo as a boilerplate for
	# printq() if $fGlob is true.
	$fGlob && echo() { printq "$@"; }

	for input do
		question "$input" || break
	done
	exit 0
}

question() {
	eprintf '%s ? ' "$1"

	# Small hack, so we can get
	# input from the user without
	# having headaches with std.in.
	read r </dev/tty
	case "$r" in
		'y') echo "$1"
			break ;;
		'q') ec=1
			break ;;
		*) ec=0
			break ;;
	esac
	unset input r
	return $ec
}

printq() {
	printf '%s' "$@" | nawk -v RS='' \
		'BEGIN {
			# Partial escape table,
			# not implemented 1-per-1
			# to KornShell 93 nor
			# GNU Broken-Again.
			esc["\a"]="\\a"
			esc["\b"]="\\b"
			esc["\f"]="\\f"
			esc["\n"]="\\n"
			esc["\r"]="\\r"
			esc["\t"]="\\t"
			esc["\v"]="\\v"
			esc["#"]="\\#"
			esc["\~"]="\\~"
			esc["'\''"]="'\''\\'\'''\''"
			esc["\\*"]="\\\\*"
			esc[";"]="\\;"
			esc["\="]="\\="
			esc["\\|"]="\\\\|"
			esc["`"]="\\`"
		}
		{
			for (c in esc) {
				gsub(c, esc[c]);
			}
			printf("'\''%s'\''\n", $0);
		}'
}

eprintf() {
	printf 1>&2 "$@"
}

main "$@"
