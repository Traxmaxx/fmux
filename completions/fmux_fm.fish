# Completions for fm function (tmux session manager)

# Function to list tmux sessions with descriptions for completion
function __fmux_fm_complete_sessions
    command tmux list-sessions -F "#{session_name}	#{session_windows} • #{t:session_activity} • #{pane_current_command}" 2>/dev/null
end

# Options
complete -c fmux_fm -s d -d "Create/attach to session based on directory" -r -a "(__fish_complete_directories)"
complete -c fmux_fm -s f -d "Find directory and create/attach to session" -f

# Sessions - dynamic completion that runs at completion time
complete -c fmux_fm -n "__fish_is_first_arg" -f -a '(__fmux_fm_complete_sessions)' -d "tmux session"