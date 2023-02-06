() {
############################
# Run sandboxed zsh shell
# Arguments:
#	Passed to bwrap
############################
function sbsh() {
	source "$HOME/.local/bin/sandbox"
	sandbox_init
	sandbox_clearenv
	sandbox_init_env
	sandbox_init_xdg
	sandbox_unshare

	bind_base
	bind_shared
	bind_gpu
	bind_wayland
	bind_x11
	bind_sound
	robind \
		$XDG_CONFIG_HOME/zsh \
		$XDG_DATA_HOME/zsh/zim \
		$XDG_CACHE_HOME/fsh \
		$XDG_CACHE_HOME/gitstatus \
		$XDG_CONFIG_HOME/bat \
		$XDG_CONFIG_HOME/fsh \
		$XDG_CONFIG_HOME/dircolors \
		$XDG_CONFIG_HOME/tmux \
		$XDG_CONFIG_HOME/npm

	change_hostname "sandbox-$$"
	sandbox_run $* $SHELL 
}

function _sandbox_sbsh_init() {
	if [[ -n $WGETRC ]]; then
		touch $WGETRC
	fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[[ -n $SANDBOX ]] && _sandbox_sbsh_init
}
