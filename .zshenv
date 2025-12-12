#environment variables
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

if [ -f /usr/local/bin/virtualenvwrapper.sh ] ; then
  source /usr/local/bin/virtualenvwrapper.sh
fi
export PATH=$HOME/.rbenv/bin:$PATH
if type rbenv > /dev/null; then
    eval "$(rbenv init - zsh)"
fi
