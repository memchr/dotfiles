[[ ${TERM} != dumb ]] && 
() {
local zcompdump=${ZSH_CACHE_DIR}/zcompdump


function _completion_grouping_enable() {
	_log_debug 1 zsh/completion "grouping enabled"
	# enable completion grouping
	zstyle ':completion:*' group-name ''
	zstyle ':completion:*:descriptions' format '[%d]'
}

function _completion_grouping_disable() {
	_log_debug 1 zsh/completion "grouping disabled"
	# enable completion grouping
	zstyle ':completion:*' group-name
	zstyle ':completion:*:descriptions' format
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# load custom functions
local fdir=$__mod__/zsh/compfunc
fpath+=($fdir)
autoload -U $fdir/*(.:t)
# Load and initialize the completion system
zmodload -i zsh/complist
autoload -Uz compinit && compinit -C -d ${zcompdump}
# Compile the completion dumpfile; significant speedup
if [[ ! ${zcompdump}.zwc -nt ${zcompdump} ]]; then
	_log_debug 2 zsh/completion "recompile zcompdump"
	zcompile ${zcompdump}
fi
# Enable caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ${zcompcache}
# Move cursor to end of word if a full completion is inserted.
setopt always_to_end
# Make globbing case insensitive.
setopt no_case_glob
# Don't beep on ambiguous completions.
setopt no_list_beep

# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# Menu
bindkey -M menuselect '^M' .accept-line
zstyle ':completion:*:*:*:*:*' menu select search

# Format
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' '+r:|?=**'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# Ignore useless commands and functions
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order 'indexes' 'parameters'

# Directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Manuals
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' sort false
zstyle ':completion:*:manuals.(^[1]*)' insert-sections suffix

# Hostname
zstyle -e ':completion:*:hosts' hosts 'reply=(
    ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts{,2} 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
    ${=${(f)"$(cat /etc/hosts 2>/dev/null; ypcat hosts 2>/dev/null)"}%%(\#)*}
    ${=${${${${(@M)${(f)"$(cat ~/.ssh/config{,.d/*(N)} 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
  )'

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# heroku autocomplete setup
HEROKU_AC_ZSH_SETUP_PATH=$HOME/.cache/heroku/autocomplete/zsh_setup &&
	test -f $HEROKU_AC_ZSH_SETUP_PATH &&
	source $HEROKU_AC_ZSH_SETUP_PATH;

# compdef
compdef _vim vi
compdef _command sandbox
compdef _grc grc
compdef _pacman_completions_installed_packages pacblame
compdef _zsh sbsh
compdef _pkg-config pkgconf
compdef _bwrap sandbox
# NOTE: play framework conflicts with sox
compdef -d play
if typeset -f pacfzf >/dev/null; then
	compdef _pacman_zsh_comp pacfzf
fi
}
