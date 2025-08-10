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

# ================================================================================================
# ASYNC GIT OPERATIONS IMPLEMENTATION
# ================================================================================================
# This theme implements asynchronous git operations using mafredri/zsh-async for better performance.
# 
# Key components:
# 1. Async worker initialization - Sets up background worker for git operations
# 2. Async git functions - Non-blocking versions of git status, info, and fetch operations  
# 3. Callback system - Handles async results and updates prompt state
# 4. State management - Maintains git information between async operations
# 5. Fallback support - Gracefully degrades to sync operations if async is unavailable
#
# The implementation is inspired by sindresorhus/pure theme but adapted for purity-enhanced's
# existing prompt structure and styling.
# ================================================================================================

# Async git state management
# These variables manage the async git operations state
typeset -gA prompt_purity_enhanced_vcs_info          # Stores git branch, action, status, behind count
typeset -g prompt_purity_enhanced_async_render_requested  # Flag to trigger prompt re-render
typeset -g prompt_purity_enhanced_async_init              # Flag to track async worker initialization
typeset -g prompt_purity_enhanced_git_fetch_pattern       # Future use for fetch patterns

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

# Check if async is available
prompt_purity_enhanced_async_available() {
	# Check if async is loaded and available
	(( $+functions[async_start_worker] )) && return 0
	# Try to load async if not loaded
	if (( $+functions[async_init] )); then
		async_init
		(( $+functions[async_start_worker] )) && return 0
	fi
	return 1
}

# Async worker initialization
prompt_purity_enhanced_async_init() {
	# Return if async is already initialized
	(( ${prompt_purity_enhanced_async_init:-0} )) && return
	
	# Check if async is available
	if ! prompt_purity_enhanced_async_available; then
		return 1
	fi
	
	prompt_purity_enhanced_async_init=1

	# Initialize async worker
	async_start_worker "prompt_purity_enhanced" -u -n
	async_register_callback "prompt_purity_enhanced" prompt_purity_enhanced_async_callback
	
	# Set up worker environment
	async_worker_eval "prompt_purity_enhanced" "
		# Set up git environment variables for better performance
		export GIT_OPTIONAL_LOCKS=0
		export GIT_TERMINAL_PROMPT=0
	"
}

# Async git fetch function
prompt_purity_enhanced_async_git_fetch() {
	# Check if we're in a git repository
	command git rev-parse --is-inside-work-tree &>/dev/null || return

	# Disable authentication prompts for non-interactive fetch
	export GIT_TERMINAL_PROMPT=0
	export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-"ssh"} -o BatchMode=yes"

	# Perform git fetch
	command git -c gc.auto=0 fetch --quiet &>/dev/null

	# Check if there is an upstream configured for this branch
	local upstream
	upstream=$(command git rev-parse --abbrev-ref @'{u}' 2>/dev/null) || return

	# Check if there are commits to pull
	local behind_count
	behind_count=$(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null)
	
	# Return the behind count if > 0
	if (( behind_count > 0 )); then
		echo "behind:$behind_count"
	fi
}

# Async git status function
prompt_purity_enhanced_async_git_status() {
	# Check if we're in a git repository
	command git rev-parse --is-inside-work-tree &>/dev/null || return

	local INDEX STATUS=""
	
	# Check if we should include untracked files
	if (( PURE_GIT_UNTRACKED_DIRTY )); then
		INDEX=$(command git status --porcelain -b 2>/dev/null)
	else
		INDEX=$(command git status --porcelain -b --untracked-files=no 2>/dev/null)
	fi

	# Only check for untracked if enabled
	if (( PURE_GIT_UNTRACKED_DIRTY )) && echo "$INDEX" | command grep -E '^\?\? ' &>/dev/null; then
		STATUS="untracked:1 $STATUS"
	fi
	if echo "$INDEX" | grep '^A  ' &>/dev/null; then
		STATUS="added:1 $STATUS"
	elif echo "$INDEX" | grep '^M  ' &>/dev/null; then
		STATUS="added:1 $STATUS"
	elif echo "$INDEX" | grep '^MM ' &>/dev/null; then
		STATUS="added:1 $STATUS"
	fi
	if echo "$INDEX" | grep '^ M ' &>/dev/null; then
		STATUS="modified:1 $STATUS"
	elif echo "$INDEX" | grep '^AM ' &>/dev/null; then
		STATUS="modified:1 $STATUS"
	elif echo "$INDEX" | grep '^MM ' &>/dev/null; then
		STATUS="modified:1 $STATUS"
	elif echo "$INDEX" | grep '^ T ' &>/dev/null; then
		STATUS="modified:1 $STATUS"
	fi
	if echo "$INDEX" | grep '^R  ' &>/dev/null; then
		STATUS="renamed:1 $STATUS"
	fi
	if echo "$INDEX" | grep '^ D ' &>/dev/null; then
		STATUS="deleted:1 $STATUS"
	elif echo "$INDEX" | grep '^D  ' &>/dev/null; then
		STATUS="deleted:1 $STATUS"
	elif echo "$INDEX" | grep '^AD ' &>/dev/null; then
		STATUS="deleted:1 $STATUS"
	fi
	if command git rev-parse --verify refs/stash >/dev/null 2>&1; then
		STATUS="stashed:1 $STATUS"
	fi
	if echo "$INDEX" | grep '^UU ' &>/dev/null; then
		STATUS="unmerged:1 $STATUS"
	fi

	# Return the git status summary
	echo "${STATUS% }"
}

# Async git info function
prompt_purity_enhanced_async_git_info() {
	# Check if we're in a git repository
	command git rev-parse --is-inside-work-tree &>/dev/null || return

	local ref branch action
	ref=$(command git symbolic-ref HEAD 2>/dev/null) || \
	ref=$(command git rev-parse --short HEAD 2>/dev/null) || return 0
	branch="${ref#refs/heads/}"

	# Get git action if any
	local git_dir
	git_dir="$(command git rev-parse --git-dir 2>/dev/null)"
	action=""
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

	# Return git info
	echo "branch:$branch action:$action"
}

# Async callback function
prompt_purity_enhanced_async_callback() {
	local job=$1 code=$2 output=$3 exec_time=$4
	local do_render=0

	case $job in
		prompt_purity_enhanced_async_git_info)
			if [[ $code -eq 0 ]]; then
				# Parse git info output
				local -A info
				for item in ${(z)output}; do
					key=${item%%:*}
					value=${item#*:}
					info[$key]=$value
				done
				
				# Update state if changed
				if [[ ${prompt_purity_enhanced_vcs_info[branch]} != ${info[branch]} ]] || \
				   [[ ${prompt_purity_enhanced_vcs_info[action]} != ${info[action]} ]]; then
					prompt_purity_enhanced_vcs_info[branch]=${info[branch]}
					prompt_purity_enhanced_vcs_info[action]=${info[action]}
					do_render=1
				fi
			fi
			;;
		prompt_purity_enhanced_async_git_status)
			if [[ $code -eq 0 ]]; then
				# Parse git status output
				local -A status
				for item in ${(z)output}; do
					key=${item%%:*}
					value=${item#*:}
					status[$key]=$value
				done
				
				# Update state if changed
				local current_status="${prompt_purity_enhanced_vcs_info[status]}"
				if [[ $current_status != $output ]]; then
					prompt_purity_enhanced_vcs_info[status]=$output
					do_render=1
				fi
			fi
			;;
		prompt_purity_enhanced_async_git_fetch)
			if [[ $code -eq 0 && -n $output ]]; then
				# Parse git fetch result
				local -A fetch_result
				for item in ${(z)output}; do
					key=${item%%:*}
					value=${item#*:}
					fetch_result[$key]=$value
				done
				
				# Update state if behind count changed
				if [[ ${prompt_purity_enhanced_vcs_info[behind]} != ${fetch_result[behind]} ]]; then
					prompt_purity_enhanced_vcs_info[behind]=${fetch_result[behind]}
					do_render=1
				fi
			else
				# Clear behind count if fetch failed or no commits behind
				if [[ -n ${prompt_purity_enhanced_vcs_info[behind]} ]]; then
					unset "prompt_purity_enhanced_vcs_info[behind]"
					do_render=1
				fi
			fi
			;;
	esac

	# Re-render prompt if needed
	(( ${prompt_purity_enhanced_async_render_requested:-$do_render} )) && prompt_purity_enhanced_render_preprompt
}

# Render the preprompt with current async state
prompt_purity_enhanced_render_preprompt() {
	# Build git info from async state
	local git_info=""
	local git_status_info=""
	
	if [[ -n ${prompt_purity_enhanced_vcs_info[branch]} ]]; then
		local git_branch_color=$(prompt_purity_enhanced_get_color git:branch yellow)
		git_info=" %F{cyan}git:%f%F{$git_branch_color}${prompt_purity_enhanced_vcs_info[branch]}%f"
		
		# Add action if present
		if [[ -n ${prompt_purity_enhanced_vcs_info[action]} ]]; then
			local action_color=$(prompt_purity_enhanced_get_color git:action yellow)
			git_info="$git_info %F{$action_color}${prompt_purity_enhanced_vcs_info[action]}%f"
		fi
	fi
	
	# Build git status from async state
	if [[ -n ${prompt_purity_enhanced_vcs_info[status]} ]]; then
		local -A status
		for item in ${(z)${prompt_purity_enhanced_vcs_info[status]}}; do
			key=${item%%:*}
			value=${item#*:}
			status[$key]=$value
		done
		
		# Convert status to symbols
		local status_symbols=""
		[[ -n ${status[untracked]} ]] && status_symbols+="%F{cyan}✩%f "
		[[ -n ${status[added]} ]] && status_symbols+="%F{green}✓%f "
		[[ -n ${status[modified]} ]] && status_symbols+="%F{blue}✶%f "
		[[ -n ${status[deleted]} ]] && status_symbols+="%F{red}✗%f "
		[[ -n ${status[renamed]} ]] && status_symbols+="%F{magenta}➜%f "
		[[ -n ${status[unmerged]} ]] && status_symbols+="%F{yellow}═%f "
		[[ -n ${status[stashed]} ]] && status_symbols+="%F{magenta}⚑%f "
		
		git_status_info=" ${status_symbols% }"
	fi
	
	# Show behind indicator if we're behind upstream
	if [[ -n ${prompt_purity_enhanced_vcs_info[behind]} ]]; then
		local prompt_purity_enhanced_preprompt="%~$git_info$git_status_info"
		# Use ANSI magic to inject the ⇣ symbol
		print -Pn "\e7\e[0G\e[`prompt_purity_enhanced_string_length $prompt_purity_enhanced_preprompt`C%F{cyan}⇣%f\e8"
	fi
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

	local exec_time_color=$(prompt_purity_enhanced_get_color execution_time yellow)
	print -P " %F{$exec_time_color}$(prompt_purity_enhanced_cmd_exec_time)%f"

	# Show virtualenv if activated
	if [[ -n $VIRTUAL_ENV ]]; then
		local venv_color=$(prompt_purity_enhanced_get_color virtualenv 242)
		local virtualenv_prompt=" %F{$venv_color}(${VIRTUAL_ENV:t})%f"
		print -P "$virtualenv_prompt"
	fi

	# Check if we're in a git repository
	if command git rev-parse --is-inside-work-tree &>/dev/null; then
		# Try to use async operations if available
		if prompt_purity_enhanced_async_init; then
			# Start async git operations
			async_job "prompt_purity_enhanced" prompt_purity_enhanced_async_git_info
			async_job "prompt_purity_enhanced" prompt_purity_enhanced_async_git_status

			# Start git fetch if enabled
			if (( ${PURITY_GIT_PULL:-1} )); then
				async_job "prompt_purity_enhanced" prompt_purity_enhanced_async_git_fetch
			fi
		else
			# Fallback to synchronous git pull check if async is not available
			if (( ${PURITY_GIT_PULL:-1} )); then
				# Use the original async implementation as a background job
				{
					# check if there is an upstream configured for this branch
					command git rev-parse --abbrev-ref @'{u}' &>/dev/null &&
					# check if there is anything to pull
					command git fetch &>/dev/null &&
					(( $(command git rev-list --right-only --count HEAD...@'{u}' 2>/dev/null) > 0 )) &&
					# some crazy ansi magic to inject the symbol into the previous line
					{
						local prompt_purity_enhanced_preprompt="%~$(git_prompt_info) $(git_prompt_status)"
						print -Pn "\e7\e[0G\e[`prompt_purity_enhanced_string_length $prompt_purity_enhanced_preprompt`C%F{cyan}⇣%f\e8"
					}
				} &!
			fi
		fi
	else
		# Clear git state if not in a git repo and async is available
		if prompt_purity_enhanced_async_available && [[ -n ${prompt_purity_enhanced_vcs_info[branch]} ]]; then
			prompt_purity_enhanced_vcs_info=()
			prompt_purity_enhanced_render_preprompt
		fi
	fi

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

# Async-aware git functions that fallback to sync if async isn't available
git_prompt_info() {
	# Use async state if available
	if [[ -n ${prompt_purity_enhanced_vcs_info[branch]} ]]; then
		local git_branch_color=$(prompt_purity_enhanced_get_color git:branch yellow)
		local git_info="$ZSH_THEME_GIT_PROMPT_PREFIX%F{$git_branch_color}${prompt_purity_enhanced_vcs_info[branch]}%f$ZSH_THEME_GIT_PROMPT_SUFFIX"
		
		# Add action if present
		if [[ -n ${prompt_purity_enhanced_vcs_info[action]} && ${prompt_purity_enhanced_vcs_info[action]} != "" ]]; then
			local action_color=$(prompt_purity_enhanced_get_color git:action yellow)
			git_info="$git_info %F{$action_color}${prompt_purity_enhanced_vcs_info[action]}%f"
		fi
		
		echo "$git_info"
	elif command git rev-parse --is-inside-work-tree &>/dev/null; then
		# Fallback to synchronous operation if async isn't ready
		local ref
		ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
		ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
		local branch="${ref#refs/heads/}"
		local action="$(prompt_purity_enhanced_git_action)"
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX${branch}$ZSH_THEME_GIT_PROMPT_SUFFIX${action}"
	fi
}

git_prompt_status() {
	# Use async state if available
	if [[ -n ${prompt_purity_enhanced_vcs_info[status]} ]]; then
		local -A status
		for item in ${(z)${prompt_purity_enhanced_vcs_info[status]}}; do
			key=${item%%:*}
			value=${item#*:}
			status[$key]=$value
		done
		
		# Convert status to symbols
		local status_symbols=""
		[[ -n ${status[untracked]} ]] && status_symbols+="$ZSH_THEME_GIT_PROMPT_UNTRACKED"
		[[ -n ${status[added]} ]] && status_symbols+="$ZSH_THEME_GIT_PROMPT_ADDED"
		[[ -n ${status[modified]} ]] && status_symbols+="$ZSH_THEME_GIT_PROMPT_MODIFIED"
		[[ -n ${status[deleted]} ]] && status_symbols+="$ZSH_THEME_GIT_PROMPT_DELETED"
		[[ -n ${status[renamed]} ]] && status_symbols+="$ZSH_THEME_GIT_PROMPT_RENAMED"
		[[ -n ${status[unmerged]} ]] && status_symbols+="$ZSH_THEME_GIT_PROMPT_UNMERGED"
		[[ -n ${status[stashed]} ]] && status_symbols+="$ZSH_THEME_GIT_PROMPT_STASHED"
		
		echo "$status_symbols"
	elif command git rev-parse --is-inside-work-tree &>/dev/null; then
		# Fallback to synchronous operation if async isn't ready
		local INDEX STATUS=""
		# Check if we should include untracked files
		if (( PURE_GIT_UNTRACKED_DIRTY )); then
			INDEX=$(command git status --porcelain -b 2> /dev/null)
		else
			INDEX=$(command git status --porcelain -b --untracked-files=no 2> /dev/null)
		fi
		
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
	fi
}

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

	# Initialize async state
	prompt_purity_enhanced_vcs_info=()
	unset prompt_purity_enhanced_async_render_requested
	unset prompt_purity_enhanced_async_init

	add-zsh-hook precmd prompt_purity_enhanced_precmd
	add-zsh-hook preexec prompt_purity_enhanced_preexec
	
	# Cleanup function for async worker
	prompt_purity_enhanced_cleanup() {
		if (( ${prompt_purity_enhanced_async_init:-0} )) && prompt_purity_enhanced_async_available; then
			async_stop_worker "prompt_purity_enhanced"
		fi
		prompt_purity_enhanced_async_init=0
	}
	
	# Add cleanup hook
	add-zsh-hook zshexit prompt_purity_enhanced_cleanup

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