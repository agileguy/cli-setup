# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.

weather () {
  city=${1:-edmonton}
  curl wttr.in/$city
}

commit () {
  message=${1:-"no-message"}
  git add -A && git commit -m $message
}

# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='eza'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='eza -alF'
alias la='eza -la'
alias ls='eza -F'
alias vibe='XDG_CURRENT_DESKTOP=GNOME /home/dan/Apps/VibeTyper.AppImage'
alias cat='batcat'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export EDITOR=nvim
export XDG_CURRENT_DESKTOP=GNOME

# Dark background
SOLARIZED_BASE03="\[\033[0;38;5;234m\]"
SOLARIZED_BASE02="\[\033[0;38;5;235m\]"
SOLARIZED_BASE01="\[\033[0;38;5;240m\]"
SOLARIZED_BASE00="\[\033[0;38;5;241m\]"
SOLARIZED_BASE0="\[\033[0;38;5;244m\]"
SOLARIZED_BASE1="\[\033[0;38;5;245m\]"
SOLARIZED_BASE2="\[\033[0;38;5;254m\]"
SOLARIZED_BASE3="\[\033[0;38;5;230m\]"
SOLARIZED_YELLOW="\[\033[0;38;5;136m\]"
SOLARIZED_ORANGE="\[\033[0;38;5;166m\]"
SOLARIZED_RED="\[\033[0;38;5;160m\]"
SOLARIZED_MAGENTA="\[\033[0;38;5;125m\]"
SOLARIZED_VIOLET="\[\033[0;38;5;61m\]"
SOLARIZED_BLUE="\[\033[0;38;5;33m\]"
SOLARIZED_CYAN="\[\033[0;38;5;37m\]"
SOLARIZED_GREEN="\[\033[0;38;5;64m\]"
SOLARIZED_RESET="\[\033[0m\]"

PS1="${SOLARIZED_GREEN}\u@\h ${SOLARIZED_BLUE}\w ${SOLARIZED_YELLOW}\$ ${SOLARIZED_RESET}"

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PATH="$HOME/.local/bin:$PATH"

if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source "$HOME/.bash-git-prompt/gitprompt.sh"
fi

eval "$(mcfly init bash)"

eval "$(zoxide init bash)"

# Create k9s symlink if it doesn't exist (snap doesn't add it to PATH)
if [ -f /snap/k9s/current/bin/k9s ] && [ ! -L /usr/bin/k9s ]; then
    sudo ln -s /snap/k9s/current/bin/k9s /usr/bin/k9s
fi
