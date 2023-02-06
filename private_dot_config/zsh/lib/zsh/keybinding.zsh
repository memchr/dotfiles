() {
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bindkey '^[OP' run-help

# allow ctrl-A and ctrl-E to move to beginning/end of line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# get possible context for a command
bindkey '^Xh' _complete_help

# history substring search
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=white,bold,bg=59"
zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
unset key

# remove ESC bindings
bindkey -r '^[,'
bindkey -r '^[/'
bindkey -r '^[~'
bindkey -r '^[^[[C'
bindkey -r '^[^[[D'
}
