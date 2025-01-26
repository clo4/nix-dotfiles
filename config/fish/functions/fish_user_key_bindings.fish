function fish_user_key_bindings
    fish_default_key_bindings
    bind \cz 'fg 2>/dev/null; commandline -f repaint'
    bind \ez 'zi; commandline -f repaint'

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
end
