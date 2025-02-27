function abbred
    set abbrfile ~/.config/fish/conf.d/abbreviations.fish
    pushd ~/.config/fish
    # If $EDITOR is set by basically anything other than fish,
    # it will be a single string that could contain multiple space-separated
    # arguments. Using 'read -at' will tokenize it like the shell would, and
    # and store that in a list.
    set -l editor vim
    if set -q EDITOR
        echo -- $EDITOR | read -at editor
    end
    $editor $abbrfile
    set editor_status $status
    popd
    if test $editor_status -gt 0
        echo "$EDITOR exited with a non-zero status code, not executing abbreviations"
        return $editor_status
    end
    echo "removing and reapplying abbreviations"
    abbr --erase (abbr --list)
    # This file can be sourced unconditionally because it only contains abbreviations,
    # which are idempotent if executed with the same name.
    source $abbrfile
end
