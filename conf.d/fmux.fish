# fmux plugin initialization

# fmux fm - Enhanced Tmux Session Manager
# Usage: 
#   fm                     - Interactive session selection
#   fm [session_name]      - Create/attach to named session
#   fm [session_name] [window_name] - Create/attach to specific window
#   fm -d [directory]      - Create/attach to session based on directory
#   fm -f                  - Find directory and create/attach to session

# Make sure the tmux command is available
if not set -q fmux__tmux_cmd
    set -g fmux_tmux_cmd "tmux"
end

# Set default search directories for -f option if not already set
# TODO: make this configurable
if not set -q fmux_search_dirs
    set -g fmux_search_dirs "$HOME/sites" "$HOME/.config"
end

# Complete session names helper
function __fmux_list_tmux_sessions
    command $fmux_tmux_cmd list-sessions -F "#S" 2>/dev/null
end

function fmux_fm
    # Helper functions
    function switch_to -a session_name
        if test -z "$TMUX"
            $fmux_tmux_cmd attach-session -t $session_name
        else
            $fmux_tmux_cmd switch-client -t $session_name
        end
    end
    
    function has_session -a session_name
        $fmux_tmux_cmd list-sessions 2>/dev/null | grep -q "^$session_name:"
    end
    

    function hydrate -a session_name directory
        set -l sessionizer_file "$directory/.tmux-sessionizer"
        set -l home_sessionizer "$HOME/.tmux-sessionizer"
        
        if test -f "$sessionizer_file"
            $fmux_tmux_cmd send-keys -t $session_name "source $sessionizer_file" C-m
        else if test -f "$home_sessionizer"
            $fmux_tmux_cmd send-keys -t $session_name "source $home_sessionizer" C-m
        end
    end
    
    function create_session_from_dir -a directory
        set -l abs_directory (realpath "$directory")
        set -l session_name (basename "$abs_directory" | tr . _)
        
        echo "Creating session '$session_name' from directory: $abs_directory"
        
        # Create session if it doesn't exist
        if not has_session "$session_name"
            $fmux_tmux_cmd new-session -ds "$session_name" -c "$abs_directory"
            hydrate "$session_name" "$abs_directory"
        end
        
        # Switch to the session
        switch_to "$session_name"
    end
    
    function select_with_fzf -a prompt items
        printf '%s\n' $items 2>/dev/null | fzf +m --cycle -1 --height=8 --layout=reverse-list --prompt="$prompt> "
    end
    
    function select_with_menu -a prompt items
        echo "$prompt:"
        set -l i 1
        for opt in $items
            echo "$i) $opt"
            set i (math $i + 1)
        end
        echo "$i) Cancel"
        
        read -P "Enter selection: " reply
        
        if test -n "$reply" -a "$reply" -ge 1 -a "$reply" -lt $i
            echo $items[(math $reply)]
            return 0
        end
        
        return 1
    end
    
    function select_item -a prompt items
        if type -q fzf
            select_with_fzf "$prompt" $items
        else
            select_with_menu "$prompt" $items
        end
    end
    
    # Parse arguments
    argparse 'h/help' 'd/directory' 'f/find' -- $argv
    or return 0
    # Checking for _flag_h and _flag_help is equivalent
    # We check if it has been given at least once
    if set -ql _flag_h
echo """fmux fm - Enhanced Tmux Session Manager
Usage: 
    fmux_fm                              - Interactive session selection
    fmux_fm [session_name]               - Create/attach to named session
    fmux_fm [session_name] [window_name] - Create/attach to specific window
    fmux_fm -d|--directory=[directory]   - Create/attach to session based on directory
    fmux_fm -f|--find                    - Find directory and create/attach to session

Tip: Create function aliases to allow direct use ogf fmux as fm and fmk commands
       alias fm='fmux_fm'
       alias fmk='fmux_fmk'"""
        
        return 1
    end


    # Directory mode (-d)
    if set -ql _flag_d
        if test (count $argv) -lt 1
            echo "Error: Directory path required with -d option"
            return 1
        end
        
        set -l directory $argv
        if not test -d "$directory"
            echo "Error: Directory does not exist: $directory"
            return 1
        end
        
        create_session_from_dir "$directory"
        set -e _fm_tmux_cmd
        return 0
    end
        
    # Find mode (-f)
    if set -ql _flag_f
        if not type -q fzf
            echo "Error: fzf is required for directory finding mode"
            return 1
        end
        
        set -l selected (find $fmux_search_dirs -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | fzf)
        
        if test -n "$selected"
            create_session_from_dir "$selected"
        end
        
        set -e _fm_tmux_cmd
        return 0
    end
    
    # Session name provided
    if test (count $argv) -ge 1
        set -l session_arg $argv[1]
        set -l window_arg ""
        if test (count $argv) -ge 2
            set window_arg $argv[2]
        end

        set -l attach ""

        # Try exact match first, then partial match
        if $fmux_tmux_cmd has-session -t "$session_arg" 2>/dev/null
            set attach "$session_arg"
        else
            for session in ($fmux_tmux_cmd ls -F '#S' 2>/dev/null)
                set -l session_lower (string lower -- "$session")
                set -l arg_lower (string lower -- "$session_arg")
                if string match -q -- "$arg_lower*" "$session_lower"
                    set attach "$session"
                    break
                end
            end
        end

        if test -n "$attach"
            # If a window was provided, try to use it
            if test -n "$window_arg"
                set -l window ""
                if string match -qr -- '^[0-9]+$' -- "$window_arg"
                    set window "$window_arg"
                else
                    for win in ($fmux_tmux_cmd list-windows -F '#W' -t "$attach" 2>/dev/null)
                        set -l win_lower (string lower -- "$win")
                        set -l warg_lower (string lower -- "$window_arg")
                        if string match -q -- "$warg_lower*" "$win_lower"
                            set window "$win"
                            break
                        end
                    end
                end

                if test -n "$window"
                    switch_to "$attach:$window"
                else
                    # Create new window with provided name
                    $fmux_tmux_cmd new-window -t "$attach" -n "$window_arg"
                    switch_to "$attach:$window_arg"
                end
            else
                switch_to "$attach"
            end
        else
            # Create new session (and window if provided)
            if test -n "$window_arg"
                echo "Creating new session $session_arg with window $window_arg"
                $fmux_tmux_cmd new -s "$session_arg" -n "$window_arg"
            else
                echo "Creating new session $session_arg"
                $fmux_tmux_cmd new -s "$session_arg"
            end
        end

        # Done handling arguments; do not fall through to interactive UI
        return 0
    end

    ####
    # No arguments - interactive selection
    ####
    # Check if tmux has active sessions
    if not $fmux_tmux_cmd ls 2>/dev/null
        echo "$argv"
        echo "No active sessions found"
    end
    
    # Select session
    set -l sessions ($fmux_tmux_cmd ls -F '#S' 2>/dev/null)
    set -l attach (select_item "Choose session" $sessions)
    
    if test -n "$attach"
        # Select window if multiple exist
        set -l windows ($fmux_tmux_cmd list-windows -t "$attach" -F '#W')
        if test (count $windows) -gt 1
            set -l window (select_item "Choose window" $windows)
            if test -n "$window"
                switch_to "$attach:$window"
            end
        else
            switch_to "$attach"
        end
    end
end

# fmux fmk - Tmux Kill Session
# Usage: fmk [session_name]
#   - With no arguments: Lists all available sessions
#   - With session_name: Kills the matching session

function fmux_fmk
    # Parse arguments
    argparse 'h/help' -- $argv
    or return 0
    # Checking for _flag_h and _flag_help is equivalent
    # We check if it has been given at least once
    if set -ql _flag_h
        echo "Tmux Kill Session" >&2
        echo "Usage: fmux_fmk [-h | --help] <sessionname>" >&2
        return 1
    end

    # Check if tmux is running with active sessions
    if not $fmux_tmux_cmd ls >/dev/null 2>&1
        echo "No tmux sessions running."
        return 1
    end

    # If no session name provided, list available sessions
    if test -z "$argv"
        echo "No session name provided"
        echo "Available sessions:"
        $fmux_tmux_cmd list-sessions
        return 0
    end
    
    # Try to find and kill the matching session
    set -l arg $argv[1]
    set -l sessions ($fmux_tmux_cmd list-sessions -F "#{session_id}:#S")
    
    # First try exact match
    for session_info in $sessions
        set -l parts (string split ":" $session_info)
        set -l session_id $parts[1]
        set -l session_name $parts[2]
        
        if test "$session_name" = "$arg"
            echo "Killing exact match: $session_name"
            $fmux_tmux_cmd kill-session -t $session_id
            return 0
        end
    end
    
    # Then try partial match (case insensitive)
    for session_info in $sessions
        set -l parts (string split ":" $session_info)
        set -l session_id $parts[1]
        set -l session_name $parts[2]
        
        if string match -qi "$arg*" "$session_name"
            echo "Killing partial match: $session_name"
            $fmux_tmux_cmd kill-session -t $session_id
            return 0
        end
    end
    
    # No matching session found
    echo "No matching session found: $arg"
    return 1
end