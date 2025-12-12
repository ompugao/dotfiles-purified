[ -f ~/.fzf.bash ] && source ~/.fzf.bash

fgh() {
  #declare -r REPO_NAME="$(ghq list | fzf --reverse +m --sync --height ${FZF_TMUX_HEIGHT:-40%})"
  declare -r REPO_NAME="$(ghq list | fzf --reverse --info=hidden +m --sync --height ${FZF_TMUX_HEIGHT:-40%})"
  echo "${REPO_NAME}"
  [[ -n "${REPO_NAME}" ]] && cd "$(ghq root)/${REPO_NAME}"
}

which fzf 1>/dev/null 2>&1
fzf_installed=$?
if [ $fzf_installed -eq 0 ]; then
    #bind -x '"\C-r": fzf-select-history'
    #bind -x '"\C-]": fzf_ghq_src'
    bind -x '"\C-]": fgh'
fi

which jump 1>/dev/null 2>&1
jump_installed=$?
if [ $jump_installed -eq 0 ]; then
	eval "$(jump shell)"
fi

which atuin 1>/dev/null 2>&1
atuin_installed=$?
if [ $atuin_installed -eq 0 ]; then
	eval "$(atuin init bash --disable-up-arrow)"
	[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
fi

note()
{
	cd $HOME/Documents/notes
	nvim $HOME/Documents/notes/journal.pn
}
