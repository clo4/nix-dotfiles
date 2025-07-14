# When used interactively, wraps eza with some nice coloring and good default options.
# When given options or used in a command substitution, delegates to system ls.

function ls --wraps ls
    if string match --quiet -- '-*' $argv; or not isatty stdout
        command ls $argv
        return
    end

    set cmd eza --long --group-directories-first --sort=Name --follow-symlinks --git --almost-all
    if path is -d .git
        and not path is -d node_modules
        $cmd --total-size $argv
    else
        $cmd $argv
    end
end
