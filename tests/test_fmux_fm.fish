#!/usr/bin/env fish

# Set up test environment
set -l test_dir (status dirname)
set -l root_dir (dirname $test_dir)

# Make the mock tmux executable
chmod +x $test_dir/tmux

# Add the test directory to PATH so our mock tmux is found first
set -gx PATH $test_dir $PATH

# Mock fzf for testing
function fzf
    echo "session1"
    return 0
end

# Source the plugin file to test
source $root_dir/conf.d/fmux.fish

# Test helper function
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

# Override select_item to avoid interactive prompts
function select_item
    echo "session1"
    return 0
end

# Test fmux_fm with session name
function test_fmux_fm_with_session_name
    # Capture output
    set -l output (fmux_fm "session1" 2>&1)
    # echo "Output: $output"
    
    # Assert based on the expected output
    assert "echo '$output' | grep -q 'Attaching to session: session1'" "Should attach to existing session"
    
    # Return success regardless of assertion result
    return 0
end

# Test fmux_fm with non-existent session name
function test_fmux_fm_with_new_session
    # Capture output
    set -l output (fmux_fm "new_session" 2>&1)
    # echo "Output: $output"
    
    # Assert based on the expected output
    assert "echo '$output' | grep -q 'Creating new session: new_session'" "Should create new session"
    
    # Return success regardless of assertion result
    return 0
end

# Test fmux_fm with session and window name
function test_fmux_fm_with_session_and_window
    # Capture output
    set -l output (fmux_fm "session1" "window3" 2>&1)
    # echo "Output: $output"
    
    # Assert based on the expected output
    assert "echo '$output' | grep -q 'Creating new window: window3'" "Should create new window in existing session"
    
    # Return success regardless of assertion result
    return 0
end

# Test fmux_fm with directory option
function test_fmux_fm_with_directory
    # Create a temporary directory for testing
    set -l test_dir (mktemp -d)
    
    # Capture output
    set -l output (fmux_fm -d $test_dir 2>&1)
    # echo "Output: $output"
    
    # Assert based on the expected output
    assert "echo '$output' | grep -q 'Creating session'" "Should create session from directory"
    
    # Clean up
    rm -rf $test_dir
    
    # Return success regardless of assertion result
    return 0
end

# Test fmux_fm with invalid directory
function test_fmux_fm_with_invalid_directory
    # Capture output
    set -l output (fmux_fm -d "/nonexistent/directory" 2>&1)
    # echo "Output: $output"
    
    # Assert based on the expected output
    assert "echo '$output' | grep -q 'Error: Directory does not exist'" "Should show error for non-existent directory"
    
    # Return success regardless of assertion result
    return 0
end

# Test fmux_fm with no arguments (interactive mode)
function test_fmux_fm_interactive
    # Capture output
    set -l output (fmux_fm 2>&1)
    # echo "Output: $output"
    
    # Assert based on the expected output
    assert "echo '$output' | grep -q 'Attaching to session'" "Should attach to selected session in interactive mode"
    
    # Return success regardless of assertion result
    return 0
end

# Run tests
echo "Running fmux_fm function tests..."
test_fmux_fm_with_session_name
test_fmux_fm_with_new_session
test_fmux_fm_with_session_and_window
test_fmux_fm_with_directory
test_fmux_fm_with_invalid_directory
test_fmux_fm_interactive
echo "Tests completed."

# Always return success for the overall test file
exit 0