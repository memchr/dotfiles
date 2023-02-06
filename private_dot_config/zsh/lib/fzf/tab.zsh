() {
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Load fzf-tab configuration
function _fzf_tab_config() {
	_log_debug 1 fzf/tab "loading fzf-tab configuration"
	# load fzf keybinding
	zstyle ':fzf-tab:*' fzf-flags --ansi --bind=${(j.,.)__fzf_bindings}
	# enable grouping
	_completion_grouping_enable
	# enable tmux popup in tmux session
	if [[ -n "$TMUX" ]]; then
		_fzf_tab_tmux_popup_enable
	fi
	_fzf_tab_preview_enable
}

# Enable tmux popup
function _fzf_tab_tmux_popup_enable() {
	_log_debug 1 fzf/tab "tmux popup enabled"
	zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
	zstyle ':fzf-tab:*' popup-min-size 50 8
	zstyle ':fzf-tab:*' fzf-min-height 20
}

# Disable tmux popup
function _fzf_tab_tmux_popup_disable() {
	_log_debug 1 fzf/tab "tmux popup disabled"
	zstyle -d ':fzf-tab:*' fzf-command
}

function _fzf_tab_preview_enable() {
	_log_debug 1 fzf/tab "preview enabled, previewer is %B%F{blue}$__fzf_previewer%b%f"

	# file
	local preview_file=$(printf '
		if [[ "$group" =~ "file" ]]; then
			%s ${(Q)realpath} $FZF_PREVIEW_COLUMNS $FZF_PREVIEW_LINES 2>/dev/null
		else
			echo $group
		fi
		' $__fzf_previewer
	)
	# environment variable
	local preview_env='echo ${(P)word}'
 	# directory
	local preview_dir='ls -1 --color=always $realpath 2>/dev/null'
	# pacman
	local preview_pacman='
 		setopt nullglob
 		case "$group" in
 		"[packages]")
 			local_db=(/var/lib/pacman/local/${word}(-[^-]#)(#c2))
 			if [[ -n $local_db[1] ]]; then
 				echo "\033[36;1m[installed]\033[0m"
 				COLUMNS=$FZF_PREVIEW_COLUMNS pacman --color=always -Qi $word 
 				COLUMNS=$FZF_PREVIEW_COLUMNS pacman --color=always -Ql $word 
 			else
 				COLUMNS=$FZF_PREVIEW_COLUMNS pacman --color=always -Si $word
 			fi ;;
 		"[package group]")
 			pacman -Sgq $word
 			;;
 		esac
	'
	# man
	local preview_man='
		MANWIDTH=$FZF_PREVIEW_COLUMNS man $word 2> /dev/null |
			if (($+commands[bat])); then
				bat -pl man --color=always
			else
 				cat
 			fi
 	'
	# systemd unit status
	local preview_systemctl='SYSTEMD_COLORS=1 systemctl status $word'
	# git
	local preview_git_checkout='
		case "$group" in
		"[modified file]") git diff $word | delta ;;
		"[recent commit object name]") git show --color=always $word | delta ;;
		*) git log --color=always $word ;;
		esac
	'
	local preview_git_show='
		case "$group" in
		"[commit tag]") git show --color=always $word ;;
		*) git show --color=always $word | delta ;;
		esac
	'
	local preview_git_diff='git diff $word | delta'
	local preview_git_log='git log --color=always $word'


	zstyle ':fzf-tab:complete:*:*' fzf-preview $preview_file
	zstyle ':fzf-tab:complete:cd:*' fzf-preview $preview_dir
	zstyle ':fzf-tab:complete:pacman:*' fzf-preview $preview_pacman
	zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview $preview_man
	zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview $preview_systemctl
	zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview $preview_git_diff
	zstyle ':fzf-tab:complete:git-log:*' fzf-preview $preview_git_log
	zstyle ':fzf-tab:complete:git-show:*' fzf-preview $preview_git_show
	zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview $preview_git_checkout
	zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
		fzf-preview $preview_env

	# disable preview for sub commands and options
	zstyle ':fzf-tab:complete:-command-:*' fzf-preview
	zstyle ':fzf-tab:complete:*:options' fzf-preview 
	zstyle ':fzf-tab:complete:*:argument-1' fzf-preview
	# disable preview for these commands
	local cmds=(
		go curl npm nvme ping gping httping dig dog journalctl
		task caddy http wget tmux gh
	)
	for c in ${cmds[@]}; do
		zstyle ":fzf-tab:complete:$c:*" fzf-preview
	done
}
}
