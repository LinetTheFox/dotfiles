if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Adds local path /bin to the PATH
export PATH=${HOME}/bin:$PATH

# Adding the aliases
source ${HOME}/.config/aliasrc

# Making a nicer prompt
# export PS1="\[\033[38;5;14m\][\[$(tput sgr0)\]\[\033[38;5;4m\]\u\[$(tput sgr0)\]\[\033[38;5;7m\]@\[$(tput sgr0)\]\[\033[38;5;6m\]\h\[$(tput sgr0)\]\[\033[38;5;14m\]][\[$(tput sgr0)\]\[\033[38;5;11m\]\W\[$(tput sgr0)\]\[\033[38;5;14m\]]\[$(tput sgr0)\]\[\033[38;5;7m\]\\$\[$(tput sgr0)\] \[$(tput sgr0)\]"
# export PS1="\[\033[38;5;14m\][\[$(tput sgr0)\]\[\033[38;5;4m\]\u\[$(tput sgr0)\]\[\033[38;5;7m\]@\[$(tput sgr0)\]\[\033[38;5;6m\]\h\[$(tput sgr0)\]\[\033[38;5;14m\]][\[$(tput sgr0)\]\[\033[38;5;11m\]\W\[$(tput sgr0)\]\[\033[38;5;14m\]]\[$(tput sgr0)\]\[\033[38;5;7m\]\[\e[$([ $? == 0 ] && printf 32 || printf 31)m\]$\[\e[0m\]\[$(tput sgr0)\] \[$(tput sgr0)\]"

export EDITOR="nvim"

export PS1="\[\e[35m\]┌\[\e[m\]\[\e[35m\]─\[\e[m\]\[\e[35m\][\[\e[m\]\[\e[36m\]\u\[\e[m\]\[\e[34m\]@\[\e[m\]\[\e[36m\]\h\[\e[m\]\[\e[35m\]]\[\e[m\]\[\e[35m\]─\[\e[m\]\[\e[35m\][\[\e[m\]\[\e[32m\]\w\[\e[m\]\[\e[35m\]]\[\e[m\]\\n\[\e[35m\]└\[\e[m\]\[\e[35m\]─\[\e[m\]\[\e[35m\]─\[\e[m\]\[\e[31m\]\\$\[\e[m\] "

# Set JDK to 11 manually since eselect doesn't seem to work with it
JAVA_HOME="/opt/openjdk-bin-11"
PATH=$JAVA_HOME/bin:$PATH
. "$HOME/.cargo/env"
