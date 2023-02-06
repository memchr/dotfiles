typeset -g __mod__=${${${0%/}%/*}:-/}
() {
local sources=(
	utils/common
	utils/shell
	utils/git
	utils/net
	utils/os
	utils/python
	utils/vm

	sandbox				# bwrap sandbox
	secrets

	zsh/option
	zsh/alias
	zsh/color
	zsh/directory
	zsh/keybinding
	zsh/completion
	 
	fzf/config
	fzf/tab				# fzf-tab
	fzf/init
	
	p10k/config			# powerlevel10k configuration
	p10k/sandbox		# powerlevel10k sandbox segment
)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
source $__mod__/log.zsh

for s in $sources; do
	s=$__mod__/${s}.zsh
	if [[ -f $s ]]; then
		_log_debug 1 init "source %F{cyan}$s%f"
		source $s
	else
		_log_error init "source %F{6}$s %F{red}not found%f"
	fi
done
} $0
unset __mod__ _name_
