() {
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alias sudo='sudo '
# colors

# ls
if (($+commands[exa])) then
	alias ll="exa -l"
	alias l="exa -la"
else
	alias ll="ls -l"
	alias l="ls -la"
fi

# git
alias lg="lazygit"

# task
alias taskui="taskwarrior-tui"

# dotfiles
if (($+commands[chezmoi])); then
	alias dflg='chezmoi re-add;lazygit -p $(chezmoi source-path)'
	alias dotfiles='cd $(chezmoi source-path)'
fi

# trash command
if (($+commands[trash])) then
	alias th="trash"
	alias thc="trash-empty"
elif (($+commands[gio])) then 
	alias th="gio trash"
	alias thc="gio trash --empty"
fi

# http server
if (($+commands[caddy])) then
	alias h="caddy file-server --listen :8000 --browse"
elif (($+commands[webfsd])) then
	alias h="webfsd -Fp 8000 -f index.html"
else
	alias h="python -m http.server"
fi

# help
alias help=run-help
alias info='info --vi-keys'

# others
if (($+commands[perl-rename])); then
	alias rename=perl-rename
fi
alias locate='locate --regex'
alias R="R --quiet"
alias luarocks51="luarocks --lua-version 5.1"
alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'
alias httping="httping -E"
function bamd() {
	brightnessctl -d 'amdgpu*' s "${1}%"
}
}
