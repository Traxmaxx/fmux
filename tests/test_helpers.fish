#!/usr/bin/env fish

# Test helpers for fmux plugin tests

# Create a mock command function that will be used instead of the real tmux
function tmux
    echo "MOCK_TMUX: $argv"
    switch $argv[1]
        case "list-sessions"
            if contains -- "-F" $argv
                echo "session1"
                echo "session2"
                echo "dev_project"
            else
                echo "session1: 1 windows (created Mon Jan 1 00:00:00 2023)"
                echo "session2: 2 windows (created Mon Jan 1 00:00:00 2023)"
                echo "dev_project: 3 windows (created Mon Jan 1 00:00:00 2023)"
            end
            return 0
        case "has-session"
            if test "$argv[3]" = "session1" -o "$argv[3]" = "session2" -o "$argv[3]" = "dev_project"
                return 0
            else
                return 1
            end
        case "list-windows"
            echo "window1"
            echo "window2"
            return 0
        case "ls"
            echo "session1: 1 windows (created Mon Jan 1 00:00:00 2023)"
            echo "session2: 2 windows (created Mon Jan 1 00:00:00 2023)"
            echo "dev_project: 3 windows (created Mon Jan 1 00:00:00 2023)"
            return 0
        case "attach-session" "switch-client"
            echo "Attaching to session: $argv[3]"
            return 0
        case "new-session"
            echo "Creating new session: $argv[3]"
            return 0
        case "new-window"
            echo "Creating new window: $argv[5]"
            return 0
        case "new"
            echo "Creating new session: $argv[3]"
            return 0
        case "kill-session"
            echo "Killing session: $argv[3]"
            return 0
        case "send-keys"
            echo "Sending keys to session: $argv[3]"
            return 0
        case "*"
            return 0
    end
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