for p in XDG_DATA_DIRS XDG_CONFIG_DIRS TERMINFO_DIRS
    set --path $p $$p
end

set -x EDITOR hx

# Setting this to an empty string makes direnv silent
set -x DIRENV_LOG_FORMAT

set -x PSQL_HISTORY $HOME/.local/share/psql/psql_history
set -l psql_history_dir (path dirname $PSQL_HISTORY)
if not test -d $psql_history_dir
    mkdir -p $psql_history_dir
end

set -x SQLITE_HISTORY $HOME/.local/share/sqlite3/sqlite_history
set -l sqlite_history_dir (path dirname $SQLITE_HISTORY)
if not test -d $sqlite_history_dir
    mkdir -p $sqlite_history_dir
end

if test -d /opt/homebrew/bin; and not contains -- /opt/homebrew/bin $PATH
    set --prepend fish_user_paths /opt/homebrew/bin
end

if set -q GHOSTTY_BIN_DIR; and not contains -- $GHOSTTY_BIN_DIR $PATH
    set --append PATH $GHOSTTY_BIN_DIR
end
