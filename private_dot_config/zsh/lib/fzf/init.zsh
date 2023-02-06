() {
if [[ -n $ZVM_VERSION ]]; then
	_log_debug 1 fzf/init "zvm found, initialization will be delayed until zvm is loaded"
	function zvm_after_init() {
		_fzf_shell_init
		_fzf_tab_config
	}
else
	_fzf_shell_init
	_fzf_tab_config
fi
}
