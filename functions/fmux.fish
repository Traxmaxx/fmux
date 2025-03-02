# fmux - Main command wrapper for the tmux session management plugin
# This is just a wrapper around the actual functions which are now
# defined in conf.d/fmux.fish as __fmux_fm and __fmux_fmk

function fmux
    echo "fmux: Please use 'fmux_fm' or 'fmux_fmk' command instead"
    echo "  fm  - Session manager (create/attach/switch)"
    echo "  fmk - Session killer"
    return 1
end