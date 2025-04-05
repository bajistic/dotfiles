# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Use bat to color man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export VISUAL=nvim
export EDITOR=nvim

# Load secrets if they exist
if [ -f ~/.env ]; then
    source ~/.env
fi
export LANG=en_US.UTF-8
export PATH="/opt/homebrew/bin:$PATH"
export LC_ALL=en_US.UTF-8

alias nv='nvim'
alias neo='nvim'

export TERM=xterm-256color

# setopt EXTENDED_GLOB
# for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
#   ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
# done

source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

autoload -Uz promptinit
promptinit
# prompt damoekri

