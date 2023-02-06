() {
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# zoxide
if (($+commands[zoxide])); then
	_log_debug 1 zsh/directory "loading zoxide"
	eval "$(zoxide init zsh)"
fi

# Append `../` to your input for each `.` you type after an initial `..`
zstyle ':zim:input' double-dot-expand yes
}
