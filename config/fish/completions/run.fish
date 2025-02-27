set -l commands (run)
complete -c run -s h -l help -fx
complete -c run -n "not __fish_seen_subcommand_from $commands" -fa "(__COMPLETE_RUN_DESCRIPTIONS=1 run)"
