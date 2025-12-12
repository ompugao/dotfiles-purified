HISTFILE=~/.zsh_hist
HISTSIZE=300000000
SAVEHIST=300000000

#MISC
unsetopt beep
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history
setopt IGNORE_EOF
setopt share_history
setopt extendedglob
setopt correct 
setopt multios
setopt magic_equal_subst
stty stop undef
bindkey -e
export EDITOR="vi"
autoload -U run-help
autoload -U run-help-git

iscygwin(){
    uname |grep -i CYGWIN >/dev/null
}
ismac(){
    uname | grep -i Darwin > /dev/null
}
islinux(){
    uname | grep -i Linux > /dev/null
}
isbsd(){
    uname | grep -i BSD > /dev/null
}

#complition
zstyle :compinstall filename "$HOME/.zshrc"

#prevent dupulication in path
typeset -U path

#history search
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end 

if [ -d ~/.zshcomp ]; then
    fpath=(~/.zshcomp/src $fpath)
    autoload -U ~/.zshcomp/src/*(:t)
fi

if [ -f ~/.zcompctl ]; then
    source ~/.zcompctl
fi

autoload -Uz compinit
if iscygwin ;then
    compinit -u
else
    compinit
fi

#reload completion functions under HOME directory
zcompreload(){
    local f
    f=(~/.zshcomp/src/*(.))
    unfunction $f:t 2> /dev/null
    autoload -U $f:t
}

#hostname completion
function print_known_hosts (){
    test -f /etc/hosts && sed -e 's/#.*//' /etc/hosts
    #	test -f $HOME/.ssh/known_hosts && tr ',' ' ' <$HOME/.ssh/known_hosts | cut -d ' ' -f1 | sed -e 's/^\[\(.*\)\]:[0-9][0-9]*$/\1/'
    test -f ~/.host.completion && cat ~/.host.completion
}
_cache_hosts=($(print_known_hosts | tr '[:blank:]' "\n" | sort -u))

#Prompt string
setopt prompt_subst
if [ "$TERM" = "dumb" ] ; then
    PROMPT=$'%n@%m:\n%~'
else
    #PROMPT=$'%{\e[32m%}%n%{\e[31m%}@%{\e[33m%}%m%{\e[36m%}:%~%{\e[0m%}\n'
    #PROMPT=$'(%{\e[32m%}%n%{\e[0m%} (%{\e[33m%}%m%{\e[0m%} (%{\e[36m%}%~%{\e[0m%})))\n'
    #local rb=$'%(?,%{\e[31m%},%{\e[35m%})(%{\e[0m%}'
    #local lb=$'%(?,%{\e[31m%},%{\e[35m%}))%{\e[0m%}'
    local rb=$'%{\e[31m%}(%{\e[0m%}'
    local lb=$'%{\e[31m%})%{\e[0m%}'
    PROMPT=$'${rb}%{\e[32m%}%n%{\e[0m%}${rb}%{\e[33m%}%m%{\e[0m%}${rb}%{\e[36m%}%~%{\e[0m%} ${rb}%{\e[37m%}%*%{\e[0m%}${lb}${lb}${lb}${lb}\n'
fi
export PROMPT2=$PROMPT\%\ 
#PROMPT=$PROMPT%#\ 
export PROMPT=$PROMPT@\ 
#export PROMPT=$PROMPT🍣\ \ 

autoload -Uz add-zsh-hook
autoload -Uz colors
colors

#Window title
if [ "$TERM" = "mlterm" -o  "$TERM" = "kterm" -o  "$TERM" = "xterm" -o "$TERM" = "screen" ];then 
    preexec (){
        emulate -L zsh
        local -a cmd; cmd=(${(z)2})
        if [ $cmd[1] = "sudo" ]; then
            print -nP "\e]0;$cmd[1] $cmd[2](${USER}@${HOST}:%~)\a"	
        else
            print -nP "\e]0;$cmd[1](${USER}@${HOST}:%~)\a"
        fi
    }

    precmd_term_title () { print -nP "\e]0;${USER}@${HOST}:%~\a"}
fi

#screen settings
function screen_minidir(){
    echo -en '\033k'
    sdir=$(pwd | sed s#${HOME}#~#)
    dirlen=$(echo $sdir | wc -c)
    if [ $dirlen -gt 19 ] ; then
            ssdir="$(echo $sdir | cut -b 1-9)~$(echo $sdir | cut -b $(($dirlen-8))-$dirlen)"
    else
        ssdir="$(echo $sdir)"
    fi
    echo $ssdir
    echo -en '\033\\'
}

if [ "$TERM" = "screen" ]; then
    _screen_buf(){
        screen_minidir
    }
    #add-zsh-hook precmd _screen_buf
    stty start ''
fi
#automatically run screen
#if [ $SHLVL = 1 ];then
#  screen -R
#fi

#tmux settings
function _tmux_rename_window_pwd(){
    [ -n "$TMUX" ] && tmux rename-window $(basename `pwd`)
}
add-zsh-hook chpwd _tmux_rename_window_pwd

setopt complete_aliases
# ls options
if [ $TERM != "dumb" ] ;then
    if islinux ; then
        if [ -f ~/.dir_colors ]; then
            eval `dircolors ~/.dir_colors`
        else
            eval `dircolors`
        fi
        alias ls='ls --color=auto --show-control-chars -p'
    elif ismac ; then
        alias ls='ls -G -e -p'
    fi
else
    if islinux ; then
        alias ls='ls --show-control-chars -p'
    elif ismac ; then
        alias ls='ls -e -p'
    fi
fi

#completion coloring
#export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
#export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
#zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# change zsh delimiter
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " _-./;@"
zstyle ':zle:*' word-style unspecified

# 以下emacs上でansi-termを動かすときの設定
if [ $TERM = "eterm-color" ];then
    # alias関係
    # minicomの文字化けを防止する
    alias minicom='minicom.sh'
    #emacs二重起動防止
    alias emacs='emacsclient'
    # 環境変数関係
    # 環境変数EDITORをemacsclientに
    export EDITOR="emacsclient"
    #端末挙動をterminalと同様にする
    TERM=xterm-color
fi

# sudo.vimに対応
# sudo vim file1 file2
# を
# vim sudo:file1 sudo:file2
# に書きかえる
sudo() {
  local args
  case $1 in
    vi|vim)
      args=()
      for arg in $@[2,-1]
      do
        if [ $arg[1] = '-' ]; then
          args[$(( 1+$#args ))]=$arg
        else
          args[$(( 1+$#args ))]="sudo:$arg"
        fi
      done
      command vim $args
      ;;
    *)
      command sudo $@
      ;;
  esac
}
# ssh-agent,ssh-addで~/.ssh/id_rsa.kinoko.dyndns.tv(秘密鍵)を認識させる。
#.bash_logoutでeval `ssh-agent -k`が必要.鍵も登録解除するならssh-add -Dを追加
#eval `ssh-agent`
#ssh-add ~/.ssh/id_rsa.kinoko.dyndns.tv
echo -n "ssh-agent: "
[ -f ~/.ssh-agent-info ] && source ~/.ssh-agent-info
ssh-add -l >&/dev/null
if [ $? = 2 ] ; then
    echo "ssh-agent: restart...."
    touch ~/.ssh-agent-info
    ssh-agent >~/.ssh-agent-info
    source ~/.ssh-agent-info
fi

function setup_application_paths() {
    local APPDIR=$1
    export PATH=$APPDIR/bin:$PATH
    export PKG_CONFIG_PATH=$APPDIR/lib/pkgconfig:$PKG_CONFIG_PATH
    export CMAKE_PREFIX_PATH=$APPDIR/:$CMAKE_PREFIX_PATH
    if ismac ; then
        export DYLD_FALLBACK_LIBRARY_PATH=$APPDIR/lib:$DYLD_FALLBACK_LIBRARY_PATH
    elif islinux ; then
        export LD_LIBRARY_PATH=$APPDIR/lib:$LD_LIBRARY_PATH
    fi
    export PYTHONPATH=$PYTHONPATH:$APPDIR/lib
    export PYTHONPATH=`python -c "from distutils.sysconfig import get_python_lib; print get_python_lib(1,prefix='$APPDIR')"`:$PYTHONPATH
    if [[ `uname -m` -eq "x86_64" ]]; then
        if ismac ; then
            export DYLD_FALLBACK_LIBRARY_PATH=$APPDIR/lib64:$DYLD_FALLBACK_LIBRARY_PATH
        elif islinux ; then
            export LD_LIBRARY_PATH=$APPDIR/lib64:$LD_LIBRARY_PATH
        fi
        export PYTHONPATH=$APPDIR/lib64:$PYTHONPATH
    fi
}

# load locally installed packages
setup_application_paths $HOME/install
if [ -d "$HOME/softwares" ] ; then
    for dir in `ls $HOME/softwares`; do
        setup_application_paths $HOME/softwares/$dir
    done
fi

# ホストごとの設定を読みこむ
h="${HOST%%.*}"
if [[ -f "$HOME/dotfiles/hosts-dep/host-$h.zshrc" ]]; then
        source "$HOME/dotfiles/hosts-dep/host-$h.zshrc"
fi
unset h

source $HOME/dotfiles/zsh/utils.zsh

#setup fasd
# see https://github.com/clvv/fasd to know how to use.
eval "$(fasd --init auto)"
#alias v='f -e vim' # quick opening files with vim
alias v='f -t -e vim -b viminfo'
alias vs='a -e vim -i'
alias o='a -e xdg-open' # quick opening files with xdg-open
alias zi='z -i'

#aliases
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias b='exit'
alias q='exit'
alias :q='exit'
alias gcc='gcc -Wall'
alias gccplus='gcc -Wall -lstdc++'
alias sl='ls'
#alias platex='source $HOME/dotfiles/bin/platex-utf8.sh'

#if ismac ; then
  #CPUNUM=$(sysctl hw.ncpu | awk '{print $2}')
#else
  #CPUNUM=$(grep -c proc /proc/cpuinfo)
#fi
#alias make="make -j${CPUNUM}"
#unset CPUNUM
alias tmux='tmux -2'
alias clip='xclip -selection clipboard'
alias clipo='xclip -selection clipboard -o'
alias necho='echo -n'
alias selec='xclip -selection primary'
alias seleco='xclip -selection primary -o'
alias zshrc='source ~/.zshrc'
alias vir='vi -R'
alias gvims='gvim --servername VIM'
alias vims='vim --servername VIM'
alias vimr='vim --servername VIM --remote'
alias today='date +%Y-%m-%d'
alias now='date +%Y%m%d-%H%M%S'
alias nri='grep -nrI . -e'
#alias awk='awk -f $HOME/dotfiles/awk/utils.awk --source'
alias PSG='ps -A |grep '
alias -g 0X0='-print0 | xargs -0 '
alias -g B='&'
alias -g C='|cut'
alias -g CF='$(cat flags)'
alias -g EG='|egrep'
alias -g ERS='2>&1'
alias -g ERSALL='1>&/dev/null 2>&1'
alias -g FL='>>flags'
alias -g G='|grep'
alias -g H='--help'
alias -g HD='|head'
alias -g L='|less'
alias -g LV='|lv'
alias -g NL='/dev/null'
alias -g S='|sort'
alias -g SEL='"$(seleco)"'
alias -g T='|tee'
alias -g TL='|tail'
alias -g U='|uniq'
alias -g X='|xargs'
alias -g XN='|xargs -d"\n"'

if islinux ; then
    function disp_dark(){ xgamma -rgamma 0.2 -ggamma 0.2 -bgamma 0.1 }
    function disp_normal(){ xgamma -rgamma 0.5 -ggamma 0.5 -bgamma 0.3 }
    function disp_bright(){ xgamma -rgamma 0.7 -ggamma 0.7 -bgamma 0.5 }
    function savepasswd(){
        local password
        echo -n "password: " 
        read -s password ; echo
        tmux bind-key y send-keys "$password"
    }
fi

setopt auto_cd
setopt auto_pushd

if ismac ; then
    setopt combining_chars
fi
