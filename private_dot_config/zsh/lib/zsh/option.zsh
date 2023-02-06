() {
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# History
#

# Remove older command from the history if a duplicate is to be added.
setopt hist_ignore_all_dups
# disable confirmation of history expansions
unsetopt hist_verify
# The file to save the history in.
if (( ! ${+HISTFILE} )) typeset -g HISTFILE=$XDG_STATE_HOME/zsh_history
# The maximum number of events stored internally and saved in the history file.
# The former is greater than the latter in case user wants HIST_EXPIRE_DUPS_FIRST.
typeset -g HISTSIZE=20000
typeset -g SAVEHIST=10000
# Don't display duplicates when searching the history.
setopt hist_find_no_dups
# Don't enter immediate duplicates into the history.
setopt hist_ignore_dups
# Remove commands from the history that begin with a space.
setopt hist_ignore_space
# Don't execute the command directly upon history expansion.
setopt hist_verify
# Cause all terminals to share the same history 'session'.
setopt share_history

#
# Changing directories
#

# Perform cd to a directory if the typed command is invalid, but is a directory.
setopt auto_cd
# Make cd push the old directory to the directory stack.
setopt auto_pushd
autoload -Uz is-at-least && if is-at-least 5.8; then
  # Don't print the working directory after a cd.
  setopt cd_silent
fi
# Don't push multiple copies of the same directory to the stack.
setopt pushd_ignore_dups
# Don't print the directory stack after pushd or popd.
setopt pushd_silent
# Have pushd without arguments act like `pushd ${HOME}`.
setopt pushd_to_home

#
# Expansion and globbing
#

setopt extended_glob

#
# Input/output
#

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -v
# vi keybinding timeout
KEYTIMEOUT=25
# Prompt for spelling correction of commands.
setopt correct
# Customize spelling correction prompt.
SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]? '
# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}
# recognize comments
setopt interactivecomments
# Append '../' to your input for each `.` you type after the initial `..`
zstyle ':zim:input' double-dot-expand yes

#
# Job control
#

# List jobs in verbose format by default.
setopt long_list_jobs
# Prevent background jobs being given a lower priority.
setopt no_bg_nice
# Prevent status report of jobs on shell exit.
setopt no_check_jobs
# Prevent SIGHUP to jobs on shell exit.
setopt no_hup

# 
# Other
#

# perform parameter expansion, comand substitution and arithemtic expansion in
# prompts
setopt prompt_subst
# perform implicit tees or cats when multiple redirections are attempted
setopt multios
# check jobs
setopt checkjobs
# zsh run-help
unalias run-help 2>/dev/null
autoload -U run-help
autoload -U run-help-sudo
}
