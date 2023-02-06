(){
typeset -gar __log_level_color=(
	"\033[32;1m"
	"\033[33;1m"
	"\033[34;1m"
	"\033[35;1m"
)

function _log_level_color() {
	local level=$1
	[[ $1 -gt 4 ]] && level=4
	echo $__log_level_color[$level]
}

function _log_debug() {
	[[ -z $ZDEBUGLEVEL ]] && return 0

	local debuglevel color log_prefix
	debuglevel="$1"
	(($# > 2)) && log_prefix="$2: " && shift
	shift
	[[ $ZDEBUGLEVEL -lt $debuglevel ]] && return 0
	[[ $debuglevel -gt 4 ]] && debuglevel=4
	print -P -- "$(_log_level_color $debuglevel)[zsh debug $debuglevel]\033[0m ${log_prefix}$*" >&2
}

function _log_error() {
	local log_prefix
	(($# > 1)) && log_prefix="$1: " && shift
	print -P -- "%B%F{red}[zsh error] ${log_prefix}$*%f%b" >&2
}
}
