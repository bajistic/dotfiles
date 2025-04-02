# Aliases

alias vrc='vim ~/.vimrc'
alias notes='cd ~/Documents/src/notes/ && vim .'
alias zrc='vim ~/.zshrc'
alias project='cd ~/Projects/Portfolio\ Enkhjin/Website/'
alias vocab=''


# export NVM_DIR="$HOME/.nvm"
# [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
# [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/node@15/bin:$PATH"
export ANDROID_HOME=/usr/local/share/android-sdk

# Use bat to color man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

alias ivault="cd /Users/bayarbileg/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents/ivault/ && nvim"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/opt/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/opt/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<

export VISUAL=nvim
export EDITOR=nvim

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"


source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.4.1

# Added by Windsurf
export PATH="/Users/bayarbileg/.codeium/windsurf/bin:$PATH"

# alias nvim="/Applications/Ghostty.app/Contents/MacOS/ghostty -e nvim"
alias zshrc="nvim ~/.zshrc"
#
# Load secrets if they exist
if [ -f ~/.env ]; then
    source ~/.env
fi
export LANG=en_US.UTF-8
export PATH="/opt/homebrew/bin:$PATH"
export LC_ALL=en_US.UTF-8

zprof
alias nv='nvim'
alias neo='nvim'

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
