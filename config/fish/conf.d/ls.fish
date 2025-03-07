# Fish bundles an 'ls' command that I don't want to override.
# I just want to add some default arguments to it, but not if
# its output is being captured or if there were any options
# provided manually.
# I fully expect that this will bite me at some point, but I
# think this is handled in the least brittle way possible.

status is-interactive; or return

functions --copy ls __fish_ls
functions --erase ls

function ls --wraps ls
    if string match --quiet -- '-*' $argv; or not isatty stdout
        __fish_ls $argv
        return
    end
    __fish_ls -lAhH $argv
end
