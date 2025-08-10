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

# Performance options
PURE_GIT_UNTRACKED_DIRTY=${PURE_GIT_UNTRACKED_DIRTY:-1}
PURE_GIT_DELAY_DIRTY_CHECK=${PURE_GIT_DELAY_DIRTY_CHECK:-1800}

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
	local exec_time_color=$(prompt_purity_enhanced_get_color execution_time yellow)
	print -P " %F{$exec_time_color}$(prompt_purity_enhanced_cmd_exec_time)%f"

	# Show virtualenv if activated
	if [[ -n $VIRTUAL_ENV ]]; then
		local venv_color=$(prompt_purity_enhanced_get_color virtualenv 242)
		local virtualenv_prompt=" %F{$venv_color}(${VIRTUAL_ENV:t})%f"
		print -P "$virtualenv_prompt"
	fi

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

# Function to get current git action (rebase, merge, etc.)
prompt_purity_enhanced_git_action() {
	local git_dir="$(command git rev-parse --git-dir 2>/dev/null)"
	[[ -z "$git_dir" ]] && return

	local action=""
	if [[ -f "$git_dir/rebase-merge/interactive" ]]; then
		action="rebase-i"
	elif [[ -d "$git_dir/rebase-merge" ]]; then
		action="rebase-m"
	elif [[ -d "$git_dir/rebase-apply" ]]; then
		if [[ -f "$git_dir/rebase-apply/rebasing" ]]; then
			action="rebase"
		elif [[ -f "$git_dir/rebase-apply/applying" ]]; then
			action="am"
		else
			action="am/rebase"
		fi
	elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
		action="merge"
	elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
		action="cherry-pick"
	elif [[ -f "$git_dir/REVERT_HEAD" ]]; then
		action="revert"
	elif [[ -f "$git_dir/BISECT_LOG" ]]; then
		action="bisect"
	fi

	if [[ -n "$action" ]]; then
		local action_color=$(prompt_purity_enhanced_get_color git:action yellow)
		echo " %F{$action_color}$action%f"
	fi
}

# Fallback git functions if oh-my-zsh is not loaded
if ! command -v git_prompt_info >/dev/null 2>&1; then
	git_prompt_info() {
		local ref
		ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
		ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
		local branch="${ref#refs/heads/}"
		local action="$(prompt_purity_enhanced_git_action)"
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX${branch}$ZSH_THEME_GIT_PROMPT_SUFFIX${action}"
	}
fi

if ! command -v git_prompt_status >/dev/null 2>&1; then
	git_prompt_status() {
		local INDEX STATUS
		# Check if we should include untracked files
		if (( PURE_GIT_UNTRACKED_DIRTY )); then
			INDEX=$(command git status --porcelain -b 2> /dev/null)
		else
			INDEX=$(command git status --porcelain -b --untracked-files=no 2> /dev/null)
		fi
		STATUS=""
		# Only check for untracked if enabled
		if (( PURE_GIT_UNTRACKED_DIRTY )) && $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
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

# Get a color value from zstyle with fallback
prompt_purity_enhanced_get_color() {
	local color_name=$1
	local default_color=$2
	local color
	zstyle -s :prompt:purity-enhanced:$color_name color color || color=$default_color
	echo $color
}

prompt_purity_enhanced_setup() {
	# prevent percentage showing up
	# if output doesn't end with a newline
	export PROMPT_EOL_MARK=''

	# Set prompt options (these only work with promptinit, so we set them directly above)
	prompt_opts=(cr subst percent)

	zmodload zsh/datetime
	zmodload zsh/zutil  # For zstyle
	autoload -Uz add-zsh-hook

	add-zsh-hook precmd prompt_purity_enhanced_precmd
	add-zsh-hook preexec prompt_purity_enhanced_preexec

	# Set up default colors (can be overridden via zstyle)
	local path_color=$(prompt_purity_enhanced_get_color path blue)
	local git_branch_color=$(prompt_purity_enhanced_get_color git:branch yellow)
	local git_action_color=$(prompt_purity_enhanced_get_color git:action yellow)
	local prompt_success_color=$(prompt_purity_enhanced_get_color prompt:success green)
	local prompt_error_color=$(prompt_purity_enhanced_get_color prompt:error red)
	local execution_time_color=$(prompt_purity_enhanced_get_color execution_time yellow)
	local virtualenv_color=$(prompt_purity_enhanced_get_color virtualenv 242)
	local suspended_jobs_color=$(prompt_purity_enhanced_get_color suspended_jobs red)
	local user_host_color=$(prompt_purity_enhanced_get_color host 242)

	# show username@host if logged in through SSH or in a container
	if [[ -n "$SSH_CONNECTION" ]] || [[ -f /.dockerenv ]] || [[ -n "$KUBERNETES_SERVICE_HOST" ]]; then
		prompt_purity_enhanced_username="%F{$user_host_color}%n@%m%f "
	fi

	# Git prompt configuration
	ZSH_THEME_GIT_PROMPT_PREFIX=" %F{cyan}git:%f%F{$git_branch_color}"
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

	# Build the prompt with suspended jobs indicator
	local jobs_indicator="%(1j.%F{$suspended_jobs_color}✦%f .)"  # Show ✦ when there are background jobs
	
	# prompt turns red if the previous command didn't exit with 0
	PROMPT="${prompt_purity_enhanced_username}%F{$path_color}%~$(git_prompt_info) $(git_prompt_status) ${jobs_indicator}%(?.%F{$prompt_success_color}.%F{$prompt_error_color})❯%f "
	RPROMPT='%F{red}%(?..⏎)%f'
}

prompt_purity_enhanced_setup "$@"