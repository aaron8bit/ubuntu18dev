# PROMPT LOOKS LIKE:
# user@hostname [pwd] (branch) %

NEWLINE=$'\n'
USER_HOST="%{${fg[yellow]}%}%n%{$reset_color%}%{${fg[yellow]}%}@%m%{$reset_color%}"
CURRENT_DIRECTORY="%{${fg[green]}%}[%c]%{$reset_color%}"
SHELL_PROMPT="%{$fg[yellow]%}%#%{$reset_color%}"

PROMPT='${USER_HOST} ${CURRENT_DIRECTORY} $(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%}) ${SHELL_PROMPT} '

#PROMPT='%{${fg[yellow]}%}%n%{$reset_color%}%{${fg[yellow]}%}@%m%{$reset_color%} %{${fg[green]}%}[%c]%{$reset_color%} $(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[yellow]%}%#%{$reset_color%} '

# user@hostname (branch) [pwd] %
#PROMPT='%{${fg[yellow]}%}%n%{$reset_color%}%{${fg[yellow]}%}@%m%{$reset_color%} $(git_prompt_info)%{${fg[green]}%}[%c]%{$reset_color%} %(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[yellow]%}%#%{$reset_color%} '

# user@hostname [pwd] %
#PROMPT='%{${fg[yellow]}%}%n%{$reset_color%}%{${fg[yellow]}%}@%m%{$reset_color%} %{${fg[green]}%}[%c]%{$reset_color%} %(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$fg[yellow]%}%#%{$reset_color%} '

# add git brach to far right
# put FQ pwd on far right side
#RPROMPT='$(git_prompt_info)%{$fg[green]%}%~%{$reset_color%}'

# put FQ pwd on far right side
RPROMPT='# %{$fg[green]%}%~%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%})%{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[red]%}X%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
