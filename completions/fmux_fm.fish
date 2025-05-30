# Completions for fm function (tmux session manager)

# Function to list tmux sessions for completion
function __fmux_list_tmux_sessions
    command tmux list-sessions -F "#{session_name}" 2>/dev/null
end

# Function to get session description
function __fmux_get_session_description
    set -l session $argv[1]
    command tmux list-sessions -F "#{session_name}~#{session_windows} • #{t:session_activity} • #{pane_current_command}" 2>/dev/null | grep "^$session~" | cut -d "~" -f 2
end

# Options
complete -e -c fmux_fm -s d -d "Create/attach to session based on directory" -r -a "(__fish_complete_directories)"
complete -e -c fmux_fm -s f -d "Find directory and create/attach to session" -f

# Sessions
for session in (__fmux_list_tmux_sessions)
    set -l s_description (__fmux_get_session_description "$session")
    complete -e -c fmux_fm -n "__fish_is_first_arg" -f -a "$session" -d "$s_description"
end