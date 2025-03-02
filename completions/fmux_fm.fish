# Completions for fm function (tmux session manager)

complete -c fmux_fm -s d -d "Create/attach to session based on directory" -r -a "(__fish_complete_directories)"
complete -c fmux_fm -s f -d "Find directory and create/attach to session" -f
complete -c fmux_fm -n "__fish_is_first_arg" -a "(__fmux_list_tmux_sessions)" -f