#!/usr/bin/env fish

# Test runner for fmux plugin

set -l test_dir (status dirname)
set -l test_files $test_dir/test_*.fish
set -l failed_tests 0
set -l total_tests 0

echo "=== Running fmux plugin tests ==="
echo

for test_file in $test_files
    set total_tests (math $total_tests + 1)
    set -l test_name (basename $test_file .fish | string replace "test_" "")
    
    echo "Running tests for: $test_name"
    echo "----------------------------------------"
    
    # Run the test in a clean environment with our mock tmux in PATH
    if fish $test_file
        echo "✓ $test_name tests passed"
    else
        set failed_tests (math $failed_tests + 1)
        echo "✗ $test_name tests failed"
    end
    
    echo
end

echo "=== Test Summary ==="
echo "Total test files: $total_tests"
echo "Failed test files: $failed_tests"
echo "Passed test files: "(math $total_tests - $failed_tests)

if test $failed_tests -eq 0
    set_color green
    echo "All tests passed!"
    set_color normal
    exit 0
else
    set_color red
    echo "Some tests failed!"
    set_color normal
    exit 1
end