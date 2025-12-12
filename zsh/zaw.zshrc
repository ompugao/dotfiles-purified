source $HOME/dotfiles/zaw/zaw.zsh
zstyle ':filter-select' case-insensitive yes

bindkey -r '^x'
bindkey '^xx' zaw
bindkey '^x^x' zaw
bindkey '^xh' zaw-history
bindkey '^x^h' zaw-history
bindkey '^xz' zaw-z
bindkey '^x^z' zaw-z

#Anything.elライクなCUIのzaw.zshやcanythingをMendeleyやgistyやz(もしくはj)と使う設定
#http://arataka.github.com/2011/04/14/zaw-zsh-or-canything-with-mendeley-gisty-and-j-z.html
zmodload zsh/parameter

function zaw-src-z() {
    # see http://stackoverflow.com/questions/452290/ for IFS trick
    IFS=$(echo -n -e "\0")
    : ${(A)candidates::=$(z \
        | sed -e 's/^[0-9\\. ]*//' -e 's/ /\\ /g' -e "s#^$HOME#~#" \
        | tac | tr '\n' '\0')}
    unset IFS
    actions=("zaw-callback-execute" "zaw-callback-replace-buffer" "zaw-callback-append-to-buffer")
    act_descriptions=("execute" "replace edit buffer" "append to edit buffer")
}

zaw-register-src -n z zaw-src-z


## zaw-src-dirstack
# http://d.hatena.ne.jp/hchbaw/20110224/zawzsh
zmodload zsh/parameter
function zaw-src-dirstack() {
    : ${(A)candidates::=$dirstack}
    actions=("zaw-callback-execute" "zaw-callback-replace-buffer" "zaw-callback-append-to-buffer")
    act_descriptions=("execute" "replace edit buffer" "append to edit buffer")
}
zaw-register-src -n dirstack zaw-src-dirstack
 
 
## zaw-src-git-dirs
# http://d.hatena.ne.jp/syohex/20121219/1355925874
function zaw-src-git-dirs () {
    local _dir=$(git rev-parse --show-cdup 2>/dev/null)
    if [ $? -eq 0 ]
    then
        candidates=( $(git ls-files ${_dir} | perl -MFile::Basename -nle \
        '$a{dirname $_}++; END{delete $a{"."}; print for sort keys %a}') )
    fi
     
    actions=("zaw-src-git-dirs-cd")
    act_descriptions=("change directory in git repos")
}
function zaw-src-git-dirs-cd () {
    BUFFER="cd $1"
    zle accept-line
}
zaw-register-src -n git-dirs zaw-src-git-dirs
 

## zaw-src-git-log
# https://github.com/yonchu/zaw-src-git-log
 
# git log pretty format: For detail, refer to "man git-log"
ZAW_SRC_GIT_LOG_LOG_FORMAT=${ZAW_SRC_GIT_LOG_LOG_FORMAT:-'%ad | %s %d[%an]'}
 
# If true, print full SHA.
ZAW_SRC_GIT_LOG_NO_ABBREV=${ZAW_SRC_GIT_LOG_NO_ABBREV:-'false'}
 
# Limit the number of commits to output.
# If set the value less than 1, output unlimitedly.
ZAW_SRC_GIT_LOG_MAX_COUNT=${ZAW_SRC_GIT_LOG_MAX_COUNT:-100}
 
# Date style (relative, local, iso, rfc, short, raw, default)
ZAW_SRC_GIT_LOG_DATE_STYLE=${ZAW_SRC_GIT_LOG_DATE_STYLE:-'short'}
 
# The function to regiter to zaw.
function zaw-src-git-log () {
    # Check git directory.
    git rev-parse -q --is-inside-work-tree > /dev/null 2>&1 || return 1
     
    # Set up option.
    local -a opt
    opt=("--pretty=format:%h $ZAW_SRC_GIT_LOG_LOG_FORMAT")
    if [ "$ZAW_SRC_GIT_LOG_NO_ABBREV" != 'false' ]; then
        opt+=('--no-abbrev')
    fi
    if [ $ZAW_SRC_GIT_LOG_MAX_COUNT -gt 0 ]; then
        opt+=("--max-count=$ZAW_SRC_GIT_LOG_MAX_COUNT")
    fi
    if [ -n "$ZAW_SRC_GIT_LOG_DATE_STYLE" ]; then
        opt+=("--date=$ZAW_SRC_GIT_LOG_DATE_STYLE")
    fi
     
    # Get git log.
    local log="$(git log "${opt[@]}")"
     
    # Set candidates.
    candidates+=(${(f)log})
    actions=("zaw-src-git-log-append-to-buffer")
    act_descriptions=("git-log for zaw")
    # Enale multi marker.
    options+=(-m)
}
# Action function.
function zaw-src-git-log-append-to-buffer () {
    local list
    local item
    for item in "$@"; do
        list+="$(echo "$item" | cut -d ' ' -f 1) "
    done
    set -- $list
     
    local buf=
    if [ $# -eq 2 ]; then
        # To diff.
        buf+="$1..$2"
    else
        # 1 or 3 or more items.
        buf+="${(j: :)@}"
    fi
    # Append left buffer.
    LBUFFER+="$buf"
}
# Register this src to zaw.
zaw-register-src -n git-log zaw-src-git-log

# vim:set ft=zsh:
