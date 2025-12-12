SHELL=/bin/bash
prefix=${HOME}
srcdir=${prefix}/3rdparty
mkdirs=${prefix}/install/bin ${prefix}/.fonts ${prefix}/.ssh ${srcdir} ${prefix}/.config ${prefix}/.config/mise ${HOME}/.local/bin
PWD=$(shell pwd)
SUDO=sudo
ISWSL := $(shell test -d /run/WSL && echo 1 || echo 0)
ifeq ($(ISWSL), 1)
GITCREDENTIAL=/mnt/c/Program\\\ Files/Git/mingw64/bin/git-credential-manager.exe
else
ifeq ($(shell test -e /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret && echo -n yes),yes)
GITCREDENTIAL=/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret
else
GITCREDENTIAL=cache\ --timeout=3600
endif
endif
#$(GITCREDENTIAL):
	#echo "$@"
	#echo ${ISWSL}

all: links mkdirs append_source install_deps install_langs install_atuin install_tools install_skkjisho install_tpm install_systemd_sshagent

$(mkdirs): 
	mkdir -p $@
.PHONY: mkdirs
mkdirs: $(mkdirs)

.PHONY: links
links: mkdirs install_alacritty_config
	touch ${prefix}/.ssh-agent-info
	#ln -sf $(addprefix ${PWD}/,$(wildcard bin/*)) ${installdir}/bin
	ln -sf ${PWD}/.inputrc    ${prefix}/.inputrc
	ln -sf ${PWD}/.gdbinit    ${prefix}/.gdbinit
	ln -sf ${PWD}/.octaverc   ${prefix}/.octaverc
	ln -sf ${PWD}/sshconfig   ${prefix}/.ssh/config
	ln -sf ${PWD}/git/.gitconfig   ${prefix}/.gitconfig
	ln -sf ${PWD}/mise_config.toml   ${prefix}/.config/mise/config.toml
	ln -sf ${PWD}/starship.toml ${prefix}/.config/starship.toml
	git config -f ~/.gitconfig.os credential.helper ${GITCREDENTIAL}
	#ln -sf ${PWD}/.zshrc      ${prefix}/.zshrc
	#ln -sf ${PWD}/.zcompctl   ${prefix}/.zcompctl
	#ln -sf ${PWD}/.zcompdump  ${prefix}/.zcompdump
	#ln -sf ${PWD}/.zshenv     ${prefix}/.zshenv
	#ln -sf ${PWD}/.bashrc     ${prefix}/.bashrc
	#ln -sf ${PWD}/.screenrc   ${prefix}/.screenrc
	#ln -sf ${PWD}/.tmux.conf  ${prefix}/.tmux.conf
	#ln -sf ${PWD}/.irbrc      ${prefix}/.irbrc
	#ln -sf ${PWD}/.xmodmaprc  ${prefix}/.xmodmaprc
	#ln -sf ${PWD}/xfce/terminalrc  ${prefix}/.config/Terminal/terminalrc
	#ln -sf ${PWD}/xfce/terminalrc-new  ${prefix}/.config/xfce4/terminal/terminalrc
	#cp ${PWD}/xfce/xfce4-keyboard-shortcuts.xml ${prefix}/.config/xfce4/xfconf/xfce-perchannel-xml/
	#ln -sf ${PWD}/kde/ompugao.colorscheme ${prefix}/.kde/share/apps/konsole/ompugao.colorscheme
	#ln -sf ${PWD}/kde/Shell.profile ${prefix}/.kde/share/apps/konsole/Shell.profile
	#ln -sf ${PWD}/.tex2imrc ${prefix}/.tex2imrc
	#ln -sf ${PWD}/.peco_config.json ${prefix}/.config/peco/config.json
	#ln -sf ${PWD}/.urxvt ${prefix}/.urxvt
	#cat ${PWD}/.Xdefaults >> ${prefix}/.Xdefaults

.PHONY: update
update:
	git stash save
	git pull origin $(git branch --show-current)
	git submodule update --init
	git stash pop ; case "$$?" in * ) exit 0 ;; esac

# universal-ctags requires: pkg-config
.PHONY: install_deps
.PHONY: aptget_update
PKGDEPS = wget curl unzip autoconf git fontconfig tmux build-essential gcc pkg-config
VIM_DEPS=python3-dev libncurses-dev luajit libluajit-5.1-dev libacl1-dev libgpm-dev libxtst-dev build-essential gcc libxmu-dev libgtk-3-dev libxpm-dev
#NVIM_DEPS=ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
NODEJS_DEPS = libatomic1
ATUIN_DEPS = build-essential gcc
aptget_update:
	${SUDO} apt-get update -y
$(PKGDEPS) $(VIM_DEPS) $(NODEJS_DEPS) $(ATUIN_DEPS): aptget_update
	@echo Install $@
	@dpkg-query --show --showformat='$${db:Status-abbrev}' $@ 2>/dev/null|grep -q '^i' || ${SUDO} apt-get install $@ -y
install_deps: $(PKGDEPS)

.PHONY: append_source
append_source: .source_appended
.source_appended:
	test -f ${prefix}/.bashrc && mv ${prefix}/.bashrc ${prefix}/.bashrc.orig; true
	test -f ${prefix}/.zshrc && mv ${prefix}/.zshrc ${prefix}/.zshrc.orig; true
	echo "source ${PWD}/.bashrc" >> ${prefix}/.bashrc
	echo "source ${PWD}/.zshrc"  >> ${prefix}/.zshrc
	echo "source ${PWD}/.screenrc" >> ${prefix}/.screenrc
	echo "source ${PWD}/.tmux.conf" >> ${prefix}/.tmux.conf
	touch ${PWD}/.source_appended

.PHONY: install_vim_deps
install_vim_deps: $(VIM_DEPS)
.PHONY: install_vim
install_vim: install_vim_deps install_mise
	${prefix}/.local/bin/mise use -g vim@latest

.PHONY: install_nvim_deps install_neovim
#install_nvim_deps: $(NVIM_DEPS)
install_neovim: install_mise #install_nvim_deps  # unnecessary to install dependencies since now installing neovim's binary
	${prefix}/.local/bin/mise plugins install neovim
	${prefix}/.local/bin/mise use -g neovim@nightly

#.PHONY: install_cmigemo
#install_cmigemo:
#	cd ${srcdir} ; \
#	if [ ! -f ${srcdir}/cmigemo.tar.gz ] ; then wget https://ompugao.mydns.jp/open/setup/cmigemo.tar.gz --no-check-certificate ; fi ;\
#	tar axvf ${srcdir}/cmigemo.tar.gz ;\
#	cd cmigemo ;\
#	./configure ;\
#	make gcc-all ;\
#	echo "install migemo" ;\
#	${SUDO} make gcc-install ;\
#	if [ ! -d ${prefix}/.vim/dict ] ;then ln -sf /usr/local/share/migemo ${prefix}/.vim/dict ;fi

.PHONY: install_sourcecodepro
install_sourcecodepro: install_deps ${prefix}/.fonts/SourceCodePro-Regular.ttf
${prefix}/.fonts/SourceCodePro-Regular.ttf:
	cd ${srcdir} ;\
		wget https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip -O sourcecodepro.zip;\
		unzip sourcecodepro.zip;\
		cp source-code-pro-2.030R-ro-1.050R-it/TTF/*.ttf ${prefix}/.fonts/;\
		cd ${prefix}/.fonts ;\
		fc-cache -vf

.PHONY: install_wezterm_config
install_wezterm_config: mkdirs
	ln -sf ${PWD}/wezterm ${HOME}/.config/wezterm

.PHONY: install_zshcomplition
install_zshcomplition: ${prefix}/.zshcomp
${prefix}/.zshcomp:
	git clone https://github.com/zsh-users/zsh-completions.git ${prefix}/.zshcomp

.PHONY: install_skkjisho
install_skkjisho: ${prefix}/.skkjisyo/SKK-JISYO.L
${prefix}/.skkjisyo/SKK-JISYO.L:
	mkdir ${prefix}/.skkjisyo ;\
	cd ${prefix}/.skkjisyo/ ;\
	wget http://openlab.ring.gr.jp/skk/skk/dic/SKK-JISYO.L

#.PHONY: install_nq
#install_nq: mkdirs
#	cd ${srcdir}; \
#	git clone https://github.com/chneukirchen/nq;\
#	cd nq;\
#	make PREFIX=${installdir} install

#.PHONY: install_cask
#install_cask:
#	curl -fsSkL https://raw.github.com/cask/cask/master/go | python

.PHONY: install_tpm
install_tpm: ${prefix}/.tmux/plugins/tpm
${prefix}/.tmux/plugins/tpm:
	git clone https://github.com/tmux-plugins/tpm ${prefix}/.tmux/plugins/tpm
	${prefix}/.tmux/plugins/tpm/bin/install_plugins

.PHONY: install_gdbextension
install_gdbextension:
	mkdir -p ${HOME}/.gdb;\
	git clone --depth 1 https://github.com/gcc-mirror/gcc.git && mv gcc/libstdc++-v3/python ${HOME}/.gdb/;\
	rm -rf gcc
	mkdir -p ${HOME}/.gdb/eigen/
	git clone --depth 1 https://gitlab.com/libeigen/eigen && mv eigen/debug/gdb/printers.py ${HOME}/.gdb/eigen/printers.py && rm eigen -rf
	touch ~/.gdb/eigen/__init__.py

.PHONY: install_lldb_extention
install_lldb_extention:
	# Eigen formatter
	#curl -fsSL https://raw.githubusercontent.com/tehrengruber/LLDB-Eigen-Data-Formatter/master/tools/install.sh | bash
	curl -fsSL https://raw.githubusercontent.com/fantaosha/LLDB-Eigen-Pretty-Printer/master/tools/install.sh | bash

${prefix}/.local/bin/mise:
	curl https://mise.run | sh

.PHONY: install_mise
install_mise: curl ${prefix}/.local/bin/mise

.PHONY: install_rust
install_rust: install_mise
	${prefix}/.local/bin/mise plugins uninstall -y rust  # remove deprecated rust installer
	${prefix}/.local/bin/mise use -g rust@latest
	${prefix}/.local/share/mise/shims/rustup component add rust-analyzer
	${prefix}/.local/bin/mise reshim

.PHONY: install_nodejs
install_nodejs: install_mise $(NODEJS_DEPS)
	${prefix}/.local/bin/mise use -g node@latest
	${prefix}/.local/bin/mise reshim

.PHONY: install_golang
install_golang: install_mise
	${prefix}/.local/bin/mise use -g go@latest
	${prefix}/.local/bin/mise reshim

.PHONY: install_deno
install_deno: install_mise
	${prefix}/.local/bin/mise use -g deno@latest
	${prefix}/.local/bin/mise reshim

.PHONY: install_langs
install_langs: install_rust install_nodejs install_golang install_deno

.PHONY: install_cargo_binstall
install_cargo_binstall: install_mise
	${prefix}/.local/bin/mise install cargo-binstall@latest

#NOTE install cargo-binstall for faster installation
.PHONY: install_tools
install_tools: links install_deps install_langs install_vim install_neovim install_cargo_binstall
	eval "$$(${prefix}/.local/bin/mise activate bash --shims)" && MISE_SKIP_RESHIM=1 ${prefix}/.local/bin/mise install
	${prefix}/.local/bin/mise reshim
	${prefix}/.local/share/mise/shims/starship config directory.truncation_length 100
	${prefix}/.local/share/mise/shims/starship config directory.truncate_to_repo false

.PHONY: install_jupyter_css
install_jupyter_css:
	mkdir -p ${HOME}/.jupyter/custom/
	ln -sf ${HOME}/dotfiles/jupyter_custom.css ${HOME}/.jupyter/custom/custom.css

#.PHONY: install_openjtalk
#install_openjtalk:
#	${SUDO} apt-get install -y open-jtalk open-jtalk-mecab-naist-jdic htsengine libhtsengine-dev hts-voice-nitech-jp-atr503-m001 vlc
#	cd ${srcdir}/; \
#		wget http://downloads.sourceforge.net/project/mmdagent/MMDAgent_Example/MMDAgent_Example-1.6/MMDAgent_Example-1.6.zip; \
#		unzip MMDAgent_Example-1.6.zip;\
#		${SUDO} cp -R MMDAgent_Example-1.6/Voice/* /usr/share/hts-voice/
#	ln -s ${pwd}/bin/jsay ${HOME}/install/bin/jsay

.PHONY: install_firacode_nerdfont
install_firacode_nerdfont: install_deps ${prefix}/.fonts/FiraCodeNerdFontMono-SemiBold.ttf
${prefix}/.fonts/FiraCodeNerdFontMono-SemiBold.ttf:
	cd ${srcdir} ;\
	if [ ! -f ${srcdir}/FiraCode.zip ] ; then wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip ;fi ;\
	cd ${prefix}/.fonts ;\
	unzip ${srcdir}/FiraCode.zip ;\
	fc-cache -vf

# .PHONY: set_guake_style
# set_guake_style:
# 	#gconftool-2 --set -t string /apps/guake/style/font/palette '#000000000000:#fc9000000000:#0000eb5a0000:#f79cf79c0000:#00000000fbac:#f5ac0000f5ac:#0000f1e6f1e6:#f5acf5acf5ac:#ce73ce73ce73:#ffff00000000:#0000ffff0000:#ffffffff0000:#00000000ffff:#ffff0000ffff:#0000ffffffff:#ffffffffffff'
# 	gconftool-2 --set -t string /apps/guake/style/font/palette '#000000000000:#fc9000000000:#0000eb5a0000:#f79cf79c0000:#8e738e73ffff:#f5ac0000f5ac:#0000f1e6f1e6:#f5acf5acf5ac:#ce73ce73ce73:#ffff00000000:#0000ffff0000:#ffffffff0000:#bfffbfffffff:#ffff0000ffff:#0000ffffffff:#ffffffffffff'

.PHONY: set_xfce_shortcuts
set_xfce_shortcuts:
	@dpkg-query --show --showformat='$${db:Status-abbrev}' xfconf 2>/dev/null|grep -q '^i' || ${SUDO} apt-get install xfconf -y
	xfconf-query -c xfce4-keyboard-shortcuts -p /commands/custom/\<Primary\>\<Alt\>t -n -t string -s xfce4-terminal
	xfconf-query -c xfwm4 -p /general/activate_action -s none

# https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login/38980986#38980986
${HOME}/.config/systemd/user/ssh-agent.service:
	mkdir -p ${HOME}/.config/systemd/user
	cp -a ssh-agent.service ${HOME}/.config/systemd/user/ssh-agent.service
.PHONY: systemd_sshagent
install_systemd_sshagent: ${HOME}/.config/systemd/user/ssh-agent.service
	systemctl enable --user ssh-agent.service
	systemctl start --user ssh-agent.service

.PHONY: set_gnome_shortcuts
set_gnome_shortcuts:
	@dpkg-query --show --showformat='$${db:Status-abbrev}' libglib2.0-bin 2>/dev/null|grep -q '^i' || ${SUDO} apt-get install libglib2.0-bin -y
	@dpkg-query --show --showformat='$${db:Status-abbrev}' gsettings-desktop-schemas 2>/dev/null|grep -q '^i' || ${SUDO} apt-get install gsettings-desktop-schemas -y
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Brighten a monitor'"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Alt>Page_Up'"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.gnome.SettingsDaemon.Power.Screen.StepUp'"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "'Darken a monitor'"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "'<Alt>Page_Down'"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "'gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power --method org.gnome.SettingsDaemon.Power.Screen.StepDown'"

.PHONY: setup_xremap
setup_xremap: install_deps
	wget https://github.com/k0kubun/xremap/releases/latest/download/xremap-linux-x86_64-x11.zip
	unzip -d xremapbin xremap-linux-x86_64-x11.zip
	chmod 755 xremapbin/xremap
	sudo mv xremapbin/xremap /usr/local/bin/
	rm -rf xremapbin xremap-linux-x86_64-x11.zip
	mkdir -p ${HOME}/.config/xremap
	mkdir -p ${HOME}/.config/autostart/
	cp xremap/thinkpad.yaml ${HOME}/.config/xremap/thinkpad.yaml
	cp xremap/xremap.desktop ${HOME}/.config/autostart/
	# NOTE input group does not exist on pure ubuntu : grep -q "^input:" /etc/group || exit
	if getent group input > /dev/null 2>&1; then ${SUDO} gpasswd -a ${USER} input; echo 'KERNEL=="uinput", GROUP="input"' | sudo tee /etc/udev/rules.d/input.rules; fi

.PHONY: install_kitty_config
install_kitty_config: mkdirs
	echo "install kitty first"
	git clone https://github.com/ompugao/kitty-config ${HOME}/.config/kitty
	cp -a kitty_wrapper.sh ${HOME}/.local/bin/kitty.sh
	chmod +x ${HOME}/.local/bin/kitty.sh
	sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ${HOME}/.local/bin/kitty.sh 40
	sudo update-alternatives --config x-terminal-emulator

${prefix}/.local/share/mise/shims/atuin: $(ATUIN_DEPS)
	${prefix}/.local/bin/mise install github:atuinsh/atuin@latest
	#${prefix}/.local/share/mise/shims/cargo install --git https://github.com/ompugao/atuin --branch feat/backspace-with-ctrl-h atuin
	curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
	# echo 'eval "$$(atuin init bash)"' >> ~/.bashrc
	# echo '[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh' >> ~/.bashrc
	${prefix}/.local/bin/mise x github:atuinsh/atuin@latest -- atuin import auto || true  # NOTE this will fail when no history file exists

.PHONY: install_atuin
install_atuin: install_deps install_rust ${prefix}/.local/share/mise/shims/atuin

#.PHONY: install_opencommit
#install_opencommit: install_nodejs
#	${prefix}/.local/bin/mise use -g npm:opencommit
#	oco confiset OCO_AI_PROVIDER=ollama OCO_MODEL=mistral OCO_GITPUSH=false OCO_EMOJI=true OCO_API_URL=http://localhost:11434/api/chat
#	# API_URL is mandatory currently. see: https://github.com/di-sukharev/opencommit/issues/416

.PHONY: install_patto
install_patto: install_deps install_rust
	cargo install --git https://github.com/ompugao/patto

${prefix}/.config/alacritty/themes:
	git clone https://github.com/eendroroy/alacritty-theme.git $@

.PHONY: install_alacritty_config
install_alacritty_config: ${prefix}/.config/alacritty/themes
	ln -sf ${PWD}/alacritty.toml   ${prefix}/.config/alacritty/alacritty.toml
