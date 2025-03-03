# Completions for fmk function (tmux session killer)

# Function to list tmux sessions for completion
function __fmux_list_tmux_sessions
    command tmux list-sessions -F "#{session_name}" 2>/dev/null
end

# Function to get session description
function __fmux_get_session_description
    set -l session $argv[1]
    command tmux list-sessions -F "#{session_name}~#{session_windows} • #{t:session_activity} • #{pane_current_command})" 2>/dev/null | grep "^$session~" | cut -d "~" -f 2
end

# Sessions
for session in (__fmux_list_tmux_sessions)
    set -l s_description (__fmux_get_session_description "$session")
    complete -c fmux_fmk -n "__fish_is_first_arg" -f -a "$session" -d "$s_description"
end