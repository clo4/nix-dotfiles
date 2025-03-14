# These variables will not be pathified by Fish by default, but
# they behave like path variables, so it makes sense to treat them
# as such.
for p in XDG_DATA_DIRS XDG_CONFIG_DIRS TERMINFO_DIRS
    # @fish-lsp-disable-next-line 3003
    set --path $p $$p
end

# It's possible that `hx` isn't available if I totally bungle my $PATH
if command -q hx
    set -x EDITOR hx
else
    set -x EDITOR vim
end

# Setting this to an empty string makes direnv silent
set -x DIRENV_LOG_FORMAT

# SQLite and Postgres both store their history files in a stupid location
# by default, so this moves the histories to the data dir where they belong.
set -x PSQL_HISTORY $HOME/.local/share/psql/psql_history
set -l psql_history_dir (path dirname $PSQL_HISTORY)
test -d $psql_history_dir; or mkdir -p $psql_history_dir

set -x SQLITE_HISTORY $HOME/.local/share/sqlite3/sqlite_history
set -l sqlite_history_dir (path dirname $SQLITE_HISTORY)
test -d $sqlite_history_dir; or mkdir -p $sqlite_history_dir

# Homebrew should be available, but I don't want anything installed by
# it to take precendence over anything installed by Nix.
if test -d /opt/homebrew/bin; and not contains -- /opt/homebrew/bin $PATH
    set --append fish_user_paths /opt/homebrew/bin
end

# Fish comes with some builtin aliases for ls, which we don't want.
# Instead, `l` is an abbreviation defined in the abbreviations.fish file.
functions -e la ll

if set -q SSH_CLIENT; or set -q SSH_TTY
    set -x BROWSER echo
end

set -x FZF_CTRL_T_COMMAND "fd --type file --strip-cwd-prefix"
set -x FZF_ALT_C_COMMAND "fd --type directory --strip-cwd-prefix"

# Something has gone wrong if the first item in these paths is not the
# user configuration directories, but *if* it isn't, correct it so that
# user functions will always win.
# Shells are not pleasant to debug, so I want to give myself a head start
# by making it hard to ignore errors.
if test $fish_function_path[1] != $HOME/.config/fish/functions
    set --prepend fish_function_path $HOME/.config/fish/functions
    echo "$(set_color brred)WARNING:$(set_color normal) $(set_color --bold)fish_function_path[1]$(set_color normal) was not $(set_color --italics)'$HOME/.config/fish/functions'$(set_color normal), fixing for this shell."
    echo "         You should take some time to figure out the root cause - something is misconfigured".
    echo
    for line in $fish_function_path
        if test $line = $HOME/.config/fish/functions
            set_color --bold
            echo -- "      -> "$line
            set_color normal
        else
            echo -- "         "$line
        end
    end
    echo
end
if test $fish_complete_path[1] != $HOME/.config/fish/completions
    set --prepend fish_complete_path $HOME/.config/fish/completions
    echo "$(set_color brred)WARNING:$(set_color normal) $(set_color --bold)fish_complete_path[1]$(set_color normal) was not $(set_color --italics)'$HOME/.config/fish/completions'$(set_color normal), fixing for this shell."
    echo "         You should take some time to figure out the root cause - something is misconfigured".
    echo
    for line in $fish_complete_path
        if test $line = $HOME/.config/fish/completions
            set_color --bold
            echo -- "      -> "$line
            set_color normal
        else
            echo -- "         "$line
        end
    end
    echo
end
