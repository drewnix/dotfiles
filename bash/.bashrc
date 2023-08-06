# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)

export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.7/site-packages


export PATH=$PATH:~/bin:~/work/bin:/opt/local/Library/Frameworks/Python.framework/Versions/2.7/bin/
export PATH=/Library/Frameworks/GDAL.framework/Programs:$PATH
export JAVA_HOME=/Library/Java/Home/

export GPG_TTY=`tty`

alias l='ls -cF'
alias ls='ls -G'
alias new='tmux new-window'

function prompt {
        local BLACK="\[\033[0;30m\]"
        local GREEN="\[\033[0;32m\]"
        local LIGHT_GREEN="\[\033[1;32m\]"
        local GRAY="\[\033[1;30m\]"
        local LIGHT_GRAY="\[\033[0;37m\]"
        local BLUE="\[\033[0;34m\]"
        local LIGHT_BLUE="\[\033[1;34m\]"
        local CYAN="\[\033[0;36m\]"
        local LIGHT_CYAN="\[\033[1;36m\]"
        local RED="\[\033[0;31m\]"
        local LIGHT_RED="\[\033[1;31m\]"
        local PURPLE="\[\033[0;35m\]"
        local LIGHT_PURPLE="\[\033[1;35m\]"
        local BROWN="\[\033[0;33m\]"
        local YELLOW="\[\033[1;33m\]"
        local WHITE="\[\033[1;37m\]"
        local NO_COLOUR="\[\033[0m\]"

        case $TERM in
                xterm*|rxvt*)
                        local TITLEBAR='\[\033]0;\u@\h:\w\007\]'
                        ;;
                *)
                        local TITLEBAR=""
                        ;;
        esac

        local temp=$(tty)
        local GRAD1=${temp:5}

        local BRIGHTGREEN="\[\033[1;32m\]";

#    local GRAY="\[\033[0;37m\]";

#    PS1="${WHITE} ( ${GREEN}\u${BRIGHTGREEN}@${GREEN}\h ${CYAN}\W${WHITE} )${GRAY} ";

export PATH="$HOME/Library/Haskell/bin:$PATH"


# Black & White
PS1="$TITLEBAR\
($WHITE$GRAY flatland$LIGHT_GRAY$WHITE$WHITE \
\w$GRAY \#$NO_COLOUR ) "
PS2="$LIGHT_RED-$RED-$WHITE-$NO_COLOUR "

# Green & Blue
#PS1="$TITLEBAR\
#$LIGHT_BLUE( $WHITE$GREEN\u$CYAN@$LIGHT_BLUE"rhombo" $GREEN:\
#$GREEN\w$CYAN \# $LIGHT_BLUE) $NO_COLOUR "
#PS2="$LIGHT_RED-$RED-$WHITE-$NO_COLOUR "

# Another black and white
#PS1="$TITLEBAR\
#( $WHITE$GRAY\u$LIGHT_GRAY@$BLACK"rhombus"$BLACK:\
#$GRAY\w$GRAY \#$NO_COLOUR ) "
#PS2="$LIGHT_RED-$RED-$WHITE-$NO_COLOUR "

# Red and white
#PS1="$TITLEBAR\
#$LIGHT_RED( $WHITE$LIGHT_RED\u$NO_COLOUR@$LIGHT_RED"rhombo"$WHITE:\
#$NO_COLOUR\w$LIGHT_RED \#$LIGHT_RED )$NO_COLOUR "
#PS2="$LIGHT_RED-$RED-$WHITE-$NO_COLOUR "

# Squarish red and white
#PS1="$TITLEBAR\
#$BLUE"andrew"$BLUE $LIGHT_BLUE\w$BLUE $BLUE"jobs:"\j$BLUE\n\
#$WHITE\#$BLUE$NO_COLOUR "
#PS2="$BLUE-$RED-$WHITE-$GREEN "



#PS1="\n\[\e[32;1m\](\[\e[37;1m\]\u\[\e[32;1m\])-(\[\e[37;1m\]jobs:\j\[\e[32;1m\])-(\[\e[37;1m\]\w\[\e[32;1m\])\n(\[\[\e[37;1m\]! \!\[\e[32;1m\])-> \[\e[0m\]"

#PS1="\u@rhombo > "


}

function elite {
PS1="\[\033[31m\]\332\304\[\033[34m\](\[\033[31m\]\u\[\033[34m\]@\[\033[31m\]"rhombo"\
\[\033[34m\])\[\033[31m\]-\[\033[34m\](\[\033[31m\]\$(date +%I:%M%P)\
\[\033[34m\]-:-\[\033[31m\]\$(date +%m)\[\033[34m\033[31m\]/\$(date +%d)\
\[\033[34m\])\[\033[31m\]\304-\[\033[34m]\\371\[\033[31m\]-\371\371\
\[\033[34m\]\372\n\[\033[31m\]\300\304\[\033[34m\](\[\033[31m\]\W\[\033[34m\])\
\[\033[31m\]\304\371\[\033[34m\]\372\[\033[00m\]"
PS2="> "
}


prompt
#elite
# for examples

