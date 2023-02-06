() {
typeset -g __fzf_previewer=tp
typeset -g __fzf_bindings=(
	ctrl-alt-f:preview-page-down
	ctrl-alt-b:preview-page-up
	ctrl-j:jump
	ctrl-alt-j:jump-accept
	alt-f:page-down
	alt-b:page-up
)

# enable fzf shell integration
function _fzf_shell_init() {
	_log_debug 1 fzf/config "shell integration enabled, previewer is %B%F{blue}$__fzf_previewer%b%f"
	FZF_CTRL_T_OPTS="--preview \"COLUMNS=\$FZF_PREVIEW_COLUMNS ${__fzf_previewer} {} \$FZF_PREVIEW_COLUMNS \$FZF_PREVIEW_LINES\" $FZF_DEFAULT_OPTS"
	if [[ -d /usr/share/fzf ]]; then
		source /usr/share/fzf/completion.zsh
		source /usr/share/fzf/key-bindings.zsh 
		bindkey -M emacs '\ed' fzf-cd-widget
		bindkey -M vicmd '\ed' fzf-cd-widget
		bindkey -M viins '\ed' fzf-cd-widget
		function fzf_zsh_help() {
			print -P "%B%F{3}C-t%b%f list files+folders in current directory, (e.g., type %F{4}git add%f , press %B%F{3}C-t%b%f, select a few files using %B%F{3}Tab%b%f, finally %B%F{3}Enter%b%f)"
			print -P "%B%F{3}C-r%b%f search history of shell commands"
			print -P "%B%F{3}M-c%b%f fuzzy change directory"
		}
	else
		_log_debug 1 fzf/config "%F{cyan}/usr/share/fzf %F{red}not found%f"
	fi
}
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# use fd or rg for faster file listing
if (( ${+commands[fd]} )); then
	_log_debug 1 fzf/config "use %B%F{blue}fd%b%f as default fzf command"
	export FZF_DEFAULT_COMMAND='command fd -c always -H --no-ignore-vcs -E .git -tf'
	export FZF_ALT_C_COMMAND='command fd -c always -H --no-ignore-vcs -E .git -td'
	function _fzf_compgen_path() {
		$FZF_DEFAULT_COMMAND "${1}"
	}
	function _fzf_compgen_dir() {
		$FZF_ALT_C_COMMAND "${1}"
	}
elif (( ${+commands[rg]} )); then
	export FZF_DEFAULT_COMMAND="command rg -uu -g '!.git' --files"
	function _fzf_compgen_path() {
		$FZF_DEFAULT_COMMAND "${1}"
	}
fi
if (( ${+commands[bat]} )); then
	export FZF_CTRL_T_OPTS="--preview 'command bat --color=always --line-range :500 {}' ${FZF_CTRL_T_OPTS}"
	export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
fi

# key bindings
export FZF_DEFAULT_OPTS="--ansi --tabstop=4 --bind=${(j.,.)__fzf_bindings}"
}
