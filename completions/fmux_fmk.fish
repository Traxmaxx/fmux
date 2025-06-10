# Completions for fmk function (tmux session killer)

# Function to list tmux sessions with descriptions for completion
function __fmux_fmk_complete_sessions
    command tmux list-sessions -F "#{session_name}	#{session_windows} • #{t:session_activity} • #{pane_current_command}" 2>/dev/null
end

# Sessions - dynamic completion that runs at completion time
complete -c fmux_fmk -n "__fish_is_first_arg" -f -a '(__fmux_fmk_complete_sessions)' -d "tmux session"