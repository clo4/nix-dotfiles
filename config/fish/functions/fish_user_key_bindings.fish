function fish_user_key_bindings
    fish_default_key_bindings
    bind ctrl-z 'fg 2>/dev/null; commandline -f repaint'
    bind alt-z 'zi; commandline -f repaint'

    # c-g for git status
    bind ctrl-g _fzf_git_status_modified

    # Not sure why but the order of these is broken by default.
    # expand-abbr needs to happen first so the cursor is
    # still over the abbreviation when it tries to expand.
    bind ' ' expand-abbr self-insert
    bind ';' expand-abbr self-insert
    bind '|' expand-abbr self-insert
    bind '&' expand-abbr self-insert
    bind '>' expand-abbr self-insert
    bind '<' expand-abbr self-insert
    bind ')' expand-abbr self-insert

    # This isn't bound by default because of the fzf keybindings.
    bind ctrl-r history-pager

    command -q trash && bind enter _execute_no_rm
end

function _fzf_git_status_modified
    set -l selected (git status --porcelain | sed 's/^.. //' | fzf --query (commandline --current-token) --multi --layout=reverse --height=40% --cycle)
    commandline --current-token --replace -- (string join ' ' -- $selected)
    commandline -f repaint
end

function _execute_no_rm
    if string match --quiet "rm *" -- (commandline)
        echo
        echo " $(set_color --background red --bold) ERROR $(set_color normal) Interactive usage of 'rm' is disabled. Use 'trash' to prevent data loss."
        echo "         (if you $(set_color --italics)need$(set_color normal) to run 'rm', use 'command rm' instead)"
        commandline ""
        commandline -f repaint
    else
        commandline -f execute
    end
end
