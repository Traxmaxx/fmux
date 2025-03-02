#!/usr/bin/env fish

# Test helpers for fmux plugin tests

# This is a mock tmux executable that will be used for testing
# It will be found first in PATH when running tests

# Log the command for debugging
# echo "MOCK_TMUX called with: $argv" >&2
function tmux
    switch $argv[1]
        case "list-sessions"
            if contains -- "-F" $argv
                if test "$argv[3]" = "#S"
                    echo "session1"
                    echo "session2"
                    echo "dev_project"
                else if test "$argv[3]" = "#{session_id}:#S"
                    # Format: $1:session1 (session ID : session name)
                    echo "\$1:session1"
                    echo "\$2:session2"
                    echo "\$3:dev_project"
                else
                    echo "session1"
                    echo "session2"
                    echo "dev_project"
                end
            else
                echo "session1: 1 windows (created Mon Jan 1 00:00:00 2023)"
                echo "session2: 2 windows (created Mon Jan 1 00:00:00 2023)"
                echo "dev_project: 3 windows (created Mon Jan 1 00:00:00 2023)"
            end
        case "has-session"
            if test "$argv[3]" = "session1" -o "$argv[3]" = "session2" -o "$argv[3]" = "dev_project"
                exit 0
            else
                exit 1
            end
        case "list-windows"
            if contains -- "-F" $argv
                if test "$argv[3]" = "#W"
                    echo "window1"
                    echo "window2"
                else
                    echo "window1"
                    echo "window2"
                end
            else
                echo "1: window1* (1 panes) [80x24]"
                echo "2: window2 (1 panes) [80x24]"
            end
        case "ls"
            if contains -- "-F" $argv
                if test "$argv[3]" = "#S"
                    echo "session1"
                    echo "session2"
                    echo "dev_project"
                else
                    echo "session1"
                    echo "session2"
                    echo "dev_project"
                end
            else
                echo "session1: 1 windows (created Mon Jan 1 00:00:00 2023)"
                echo "session2: 2 windows (created Mon Jan 1 00:00:00 2023)"
                echo "dev_project: 3 windows (created Mon Jan 1 00:00:00 2023)"
            end
        case "attach-session" "switch-client"
            echo "Attaching to session: $argv[3]"
        case "new-session"
            echo "Creating new session: $argv[3]"
        case "new-window"
            echo "Creating new window: $argv[5]"
        case "new"
            if contains -- "-s" $argv
                set -l session_index (contains -i -- "-s" $argv)
                set -l session_name $argv[(math $session_index + 1)]
                echo "Creating new session: $session_name"
            else
                echo "Creating new session"
            end
        case "kill-session"
            if contains -- "-t" $argv
                set -l session_index (contains -i -- "-t" $argv)
                set -l session_id $argv[(math $session_index + 1)]
                echo "Killing session: $session_id"
            else
                echo "Killing session"
            end
        case "send-keys"
            echo "Sending keys to session: $argv[3]"
    end

    exit 0
end

# Mock fzf for testing
function fzf
    echo "session1"
    return 0
end

# Test assertion helper
function assert
    set -l condition $argv[1]
    set -l message $argv[2]
    
    if eval $condition
        set_color green
        echo "✓ $message"
        set_color normal
        return 0
    else
        set_color red
        echo "✗ $message"
        set_color normal
        return 1
    end
end

# Setup test environment
function setup_test_env
    # Add the current directory to PATH so our mock tmux is found first
    set -l test_dir (status dirname)
    set -gx PATH $test_dir $PATH
    
    # Set the tmux command to just "tmux" which will use our mock
    set -g fmux_tmux_cmd "tmux"
end