set -l commands (run 2>/dev/null)
complete -c run -s h -l help -fx
complete -c run -n "not __fish_seen_subcommand_from $commands" -fa "(__COMPLETE_RUN_DESCRIPTIONS=1 run 2>/dev/null)"
