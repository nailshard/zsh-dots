#!/usr/bin/env/zsh
_systemctl_unit_state() {
  typeset -gA _sys_unit_state
  _sys_unit_state=( $(__systemctl list-unit-files "$PREFIX*" | awk '{print $1, $2}') )
}


# bindkey  vi-cmd-mode
# bindkey -v
### Added by ZI's installer
if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing %F{33}ZI%F{220} Initiative Plugin Manager (%F{33}z-shell/zi%F{220})…%f"
  command mkdir -p "$HOME/.zi" && command chmod g-rwX "$HOME/.zi"
  command git clone https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source /etc/profile.d/fzf-extras.zsh
source "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi
### End of ZI's installer chunk
#####################
# PROMPT            #
#####################
export STARSHIP_CONFIG=$HOME/.config/zsh/starship.toml

zi ice as"command" from"gh-r" \
  atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
  atpull"%atclone" src"init.zsh"
zi light starship/starship
##########################
# OMZ Libs and Plugins   #
##########################

# IMPORTANT:
# Ohmyzsh plugins and libs are loaded first as some these sets some defaults which are required later on.
# Otherwise something will look messed up
# ie. some settings help zsh-autosuggestions to clear after tab completion

setopt promptsubst

# Explanation:
# - Loading tmux first, to prevent jumps when tmux is loaded after .zshrc
# - History plugin is loaded early (as it has some defaults) to prevent empty history stack for other plugins
zi lucid for \
atinit"\
  ZSH_TMUX_FIXTERM_WITH_256COLOR=true \
  ZSH_TMUX_AUTOSTART=true \
  ZSH_TMUX_AUTOCONNECT=false \
  ZSH_TMUX_UNICODE=true \
  ZSH_TMUX_DEFAULT_SESSION_NAME=true" \
OMZP::tmux \
  atinit"HIST_STAMPS=dd.mm.yyyy" \
OMZL::history.zsh \

# OMZL::completion.zsh \
zi wait lucid for \
OMZL::clipboard.zsh \
OMZL::compfix.zsh \
OMZL::correction.zsh \
  atload"\
  alias ..='cd ..' \
  alias ...='cd ../..' \
  alias ....='cd ../../..' \
  alias .....='cd ../../../..'" \
OMZL::directories.zsh \
OMZL::git.zsh \
OMZL::grep.zsh \
OMZL::key-bindings.zsh \
OMZL::spectrum.zsh \
OMZL::termsupport.zsh \
  atload"\
  alias gcd='gco dev'" \
OMZP::zsh-interactive-cd \
OMZP::git \
  atload"\
  alias dcupb='docker-compose up --build'" \
OMZP::docker-compose \
  as"completion" \
OMZP::docker/_docker \
  djui/alias-tips \
OMZP::systemd
  # hlissner/zsh-autopair \
  # chriskempson/base16-shell

#####################
# PLUGINS           #
#####################
# @source: https://github.com/crivotz/dot_files/blob/master/linux/zplugin/zshrc

# IMPORTANT:
# These plugins should be loaded after ohmyzsh plugins
# atinit" \
 # zstyle ':completion:*' completer _expand _complete _ignored _approximate
  # zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' \
  # zstyle ':completion:*' menu select=2 \
  # zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s' \
  # zstyle ':completion:*:descriptions' format '-- %d --' \
  # zstyle ':completion:*:processes' command 'ps -au$USER' \
  # zstyle ':completion:complete:*:options' sort false \
  #  zstyle ':fzf-tab:complete:_zlua:*' query-string input \
  # zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm,cmd -w -w' \
# zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap
# zstyle ':fzf-tab:complete:cd:*' extra-opts --preview=$extract'exa -1 --color=always ${~ctxt[hpre]}$in'
zi ice atclone"dircolors -b LS_COLORS > c.zsh" \  atpull'%atclone' pick"c.zsh" nocompile'!'zi light trapd00r/LS_COLORS

zi wait lucid for \
light-mode atinit"ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20" atload"_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions \
light-mode atinit"typeset -gA FAST_HIGHLIGHT; FAST_HIGHLIGHT[git-cmsg-len]=100; zicompinit; zicdreplay;" \
  z-shell/F-Sy-H \
light-mode blockf atpull'zi creinstall  .' \
  zsh-users/zsh-completions \
bindmap"^R -> ^H" atinit"\
  zstyle :history-search-multi-word page-size 10 \
  zstyle :history-search-multi-word highlight-color fg=red,bold \
  zstyle :plugin:history-search-multi-word reset-prompt-protect 1" \
  z-shell/H-S-MW \
reset \
atclone"local P=${${(M)OSTYPE:#*darwin*}:+g}${P}sed -i '/DIR/c\DIR 38;5;63;1' LS_COLORS; ${P}dircolors -b LS_COLORS > c.zsh" \
atpull'%atclone' pick"c.zsh" nocompile'!' \
light-mode Aloxaf/fzf-tab

# bindkey -rpM viins '^[^['
MODE_CURSOR_VIINS="blinking block #59f176"
MODE_CURSOR_REPLACE="steady block #ff4242"
MODE_CURSOR_VICMD="#66b0ff line"
MODE_CURSOR_SEARCH="#f10596 steady underline"
MODE_CURSOR_VISUAL="steady bar #cba111"
MODE_CURSOR_VLINE="steady block #00ffff"

#####################
# PROGRAMS or not   #
#####################

zi wait'1' lucid light-mode for \
   softmoth/zsh-vim-mode \
from"gh-r" as"program" \
  junegunn/fzf \
pick"z.sh" \
  knu/z \
as'command' atinit'export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"' pick"bin/n" \
  tj/n \
from'gh-r' as'command' atinit'export PATH="$HOME/.yarn/bin:$PATH"' mv'yarn* -> yarn' pick"yarn/bin/yarn" bpick'*.tar.gz' \
  yarnpkg/yarn \

  zi ice from'gh-r' as'program' mv'fd* fd' sbin'**/fd(.exe|) -> fd'
zi light @sharkdp/fd

zi ice from'gh-r' as'program' mv'bat* bat' sbin'**/bat(.exe|) -> bat'
zi light @sharkdp/bat

zi ice from'gh-r' as'program' mv'hexyl* hexyl' sbin'**/hexyl(.exe|) -> hexyl'
zi light @sharkdp/hexyl

zi ice from'gh-r' as'program' mv"hyperfine* hyperfine" sbin"**/hyperfine(.exe|) -> hyperfine"
zi light @sharkdp/hyperfine

zi ice from'gh-r' as'program' mv'vivid* vivid' sbin'**/vivid(.exe|) -> vivid'
zi light @sharkdp/vivid

zi ice from'gh-r' as'program' sbin'**/exa -> exa' atclone'cp -vf completions/exa.zsh _exa'
zi light ogham/exa


zi ice as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
  atpull'%atclone' src"zhook.zsh"
zi light direnv/direnv

zi ice as'program' from'gh-r' mv'gotcha_* -> gotcha'
zi light b4b4r07/gotcha

zi ice wait lucid as'program' cp'wd.sh -> wd' \
  mv'_wd.sh -> _wd' atpull'!git reset --hard' pick'wd'
zi light mfaerevaag/wd

zi ice wait lucid as'program' pick'bin/git-dsf'
zi load z-shell/zsh-diff-so-fancy

zi ice lucid wait as'program' has'bat' pick'src/*'
zi light eth-p/bat-extras

zi ice lucid wait as'program' has'git' \
  atclone"cp git-open.1.md $ZI[MAN_DIR]/man1/git-open.1" atpull'%atclone'
zi light paulirish/git-open

zi ice lucid wait as'program' pick'prettyping' has'ping'
zi light denilsonsa/prettyping


zi ice lucid wait as'program' has'perl' has'convert' pick'exiftool'
zi light exiftool/exiftool

zi for as'program' atclone"autoreconf -i; ./configure --prefix=$ZPFX" \
  atpull'%atclone' make"all install" pick"$ZPFX/bin/cmatrix" \
    abishekvashok/cmatrix

zi ice atclone'PYENV_ROOT="$PWD" ./libexec/pyenv init - > zpyenv.zsh' \
  atinit'export PYENV_ROOT="$PWD"' atpull"%atclone" \
  as'program' pick'bin/pyenv' src"zpyenv.zsh" nocompile'!'
zi light pyenv/pyenv

zi ice as"program" wait lucid atinit"export PYTHONPATH=$ZPFX/lib/python3.10/site-packages/" \
  atclone"PYTHONPATH=$ZPFX/lib/python3.10/site-packages/ python3 setup.py --quiet install --prefix $ZPFX" \
  atpull"%atclone" test"0" pick"$ZPFX/bin/asciinema"
zi load asciinema/asciinema

zi ice rustup cargo'!lsd' id-as'lsd' as'program' nocompile
zi load z-shell/0

zi ice id-as"rust" wait"0" lucid rustup as"program" pick"bin/rustc" \
  atload="export nocompile CARGO_HOME=\$PWD RUSTUP_HOME=\$PWD/rustup"
zi load z-shell/0

zi wait lucid for \
  has'exa' atinit'AUTOCD=1' \
    zplugin/zsh-exa

# zi wait lucid for as"command" from"gh-r" sbin"grex" \
#   pemistahl/grex

# zi wait lucid for if"(( ! ${+commands[jq]} ))" as"null" \
#   atclone"autoreconf -fi && ./configure --with-oniguruma=builtin && make \
#   && ln -sfv $PWD/jq.1 $ZI[MAN_DIR]/man1" sbin"jq" \
#     stedolan/jq



#####################
# Misc Stuff        #
#####################


setopt append_history         # Allow multiple sessions to append to one Zsh command history.
setopt extended_history       # Show timestamp in history.
setopt hist_expire_dups_first # Expire A duplicate event first when trimming history.
setopt hist_find_no_dups      # Do not display a previously found event.
setopt hist_ignore_all_dups   # Remove older duplicate entries from history.
setopt hist_ignore_dups       # Do not record an event that was just recorded again.
setopt hist_ignore_space      # Do not record an Event Starting With A Space.
setopt hist_reduce_blanks     # Remove superfluous blanks from history items.
setopt hist_save_no_dups      # Do not write a duplicate event to the history file.
setopt hist_verify            # Do not execute immediately upon history expansion.
setopt inc_append_history     # Write to the history file immediately, not when the shell exit

setopt auto_cd              # Use cd by typing directory name if it's not a command.
setopt auto_list            # Automatically list choices on ambiguous completion.
setopt auto_pushd           # Make cd push the old directory onto the directory stack.
setopt bang_hist            # Treat the '!' character, especially during Expansion.
setopt interactive_comments # Comments even in interactive shells.
setopt multios              # Implicit tees or cats when multiple redirections are attempted.
setopt no_beep              # Don't beep on error.
setopt prompt_subst         # Substitution of parameters inside the prompt each time the prompt is drawn.
setopt pushd_ignore_dups    # Don't push multiple copies directory onto the directory stack.
setopt pushd_minus
# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
# zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
#   [[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'
# it is an example. you can change it
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
	'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
	'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
	'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
	'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
	'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
	esac'
   zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
  \u00a6 '(out=$(tldr --color always "$word") 2>/dev/null && echo $out) || (out=$(MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word") 2>/dev/null && echo $out) || (out=$(which "$word") && echo $out) || echo "${(P)word}"'










zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' rehash true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# # disable sort when completing `git checkout`
# # zstyle ':completion:*:git-checkout:*' sort false
# # set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# # set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# # preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# # switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
eval "$(direnv hook zsh)"
source <(/usr/bin/starship init zsh --print-full-init)
#tmux source ~/.tmux.conf
