# Purity Enhanced
# by Stefan Petovsky
# https://github.com/speto/purity-enhanced
# MIT License

# For my own and others sanity
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path with $HOME resolved as tilde ~
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)

# Ensure prompt substitution is enabled (required for functions in prompt)
setopt promptsubst

# turns seconds into human readable time
# 165392 => 1d 21h 56m 32s
prompt_purity_enhanced_human_time() {
	local tmp=$1
	local days=$(( tmp / 60 / 60 / 24 ))
	local hours=$(( tmp / 60 / 60 % 24 ))
	local minutes=$(( tmp / 60 % 60 ))
	local seconds=$(( tmp % 60 ))
	echo -n "⌚︎ "
	(( $days > 0 )) && echo -n "${days}d "
	(( $hours > 0 )) && echo -n "${hours}h "
	(( $minutes > 0 )) && echo -n "${minutes}m "
	echo "${seconds}s"
}

# displays the exec time of the last command if set threshold was exceeded
prompt_purity_enhanced_cmd_exec_time() {
	local stop=$EPOCHSECONDS
	local start=${cmd_timestamp:-$stop}
	integer elapsed=$stop-$start
	(($elapsed > ${PURITY_CMD_MAX_EXEC_TIME:=5})) && prompt_purity_enhanced_human_time $elapsed
}

prompt_purity_enhanced_preexec() {
	cmd_timestamp=$EPOCHSECONDS

	# shows the current dir and executed command in the title when a process is active
	print -Pn "\e]0;"
	echo -nE "%~: $2"
	print -Pn "\a"
}

# string length ignoring ansi escapes
prompt_purity_enhanced_string_length() {
	echo ${#${(S%%)1//(\%([KF1]|)\{*\}|\%[Bbkf])}}
}

prompt_purity_enhanced_precmd() {
	# shows the full path in the title
	print -Pn '\e]0;%~\a'

	local prompt_purity_enhanced_preprompt="%~$(git_prompt_info) $(git_prompt_status)"
	print -P " %F{yellow}$(prompt_purity_enhanced_cmd_exec_time)%f"

	# check async if there is anything to pull
	(( ${PURITY_GIT_PULL:-1} )) && {
		# check if we're in a git repo
		command git rev-parse --is-inside-work-tree &>/dev/null &&
		# check check if there is anything to pull
		command git fetch &>/dev/null &&
		# check if there is an upstream configured for this branch
		command git rev-parse --abbrev-ref @'{u}' &>/dev/null &&
		(( $(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null) > 0 )) &&
		# some crazy ansi magic to inject the symbol into the previous line
		print -Pn "\e7\e[0G\e[`prompt_purity_enhanced_string_length $prompt_purity_enhanced_preprompt`C%F{cyan}⇣%f\e8"
	} &!

	# reset value since `preexec` isn't always triggered
	unset cmd_timestamp
}

# Fallback git functions if oh-my-zsh is not loaded
if ! command -v git_prompt_info >/dev/null 2>&1; then
	git_prompt_info() {
		local ref
		ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
		ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
	}
fi

if ! command -v git_prompt_status >/dev/null 2>&1; then
	git_prompt_status() {
		local INDEX STATUS
		INDEX=$(command git status --porcelain -b 2> /dev/null)
		STATUS=""
		if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
		fi
		if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
		elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
		elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
		fi
		if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
		elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
		elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
		elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
		fi
		if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
		fi
		if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
		elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
		elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
		fi
		if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
			STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
		fi
		if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
			STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
		fi
		echo $STATUS
	}
fi

prompt_purity_enhanced_setup() {
	# prevent percentage showing up
	# if output doesn't end with a newline
	export PROMPT_EOL_MARK=''

	# Set prompt options (these only work with promptinit, so we set them directly above)
	prompt_opts=(cr subst percent)

	zmodload zsh/datetime
	autoload -Uz add-zsh-hook

	add-zsh-hook precmd prompt_purity_enhanced_precmd
	add-zsh-hook preexec prompt_purity_enhanced_preexec

	# show username@host if logged in through SSH
	[[ "$SSH_CONNECTION" != '' ]] && prompt_purity_enhanced_username='%n@%m '

	# Git prompt configuration
	ZSH_THEME_GIT_PROMPT_PREFIX=" %F{cyan}git:%f%F{yellow}"
	ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
	ZSH_THEME_GIT_PROMPT_DIRTY=""
	ZSH_THEME_GIT_PROMPT_CLEAN=""

	ZSH_THEME_GIT_PROMPT_ADDED="%F{green}✓%f "
	ZSH_THEME_GIT_PROMPT_MODIFIED="%F{blue}✶%f "
	ZSH_THEME_GIT_PROMPT_DELETED="%F{red}✗%f "
	ZSH_THEME_GIT_PROMPT_RENAMED="%F{magenta}➜%f "
	ZSH_THEME_GIT_PROMPT_UNMERGED="%F{yellow}═%f "
	ZSH_THEME_GIT_PROMPT_UNTRACKED="%F{cyan}✩%f "
	ZSH_THEME_GIT_PROMPT_STASHED="%F{magenta}⚑%f "

	# prompt turns red if the previous command didn't exit with 0
	PROMPT='%F{blue}%~$(git_prompt_info) $(git_prompt_status) %(?.%F{green}.%F{red})❯%f '
	RPROMPT='%F{red}%(?..⏎)%f'
}

prompt_purity_enhanced_setup "$@"