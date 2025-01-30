# This function can't be lazy loaded because it needs to wrap another fish function,
# not a builtin or command. In a normal fish distribution, `man` is guaranteed to be
# a function.

functions --copy man __fish_man
functions --erase man

function man --wraps man
    if not set -q MANWIDTH
        set --function MANWIDTH 80
    end
    set --function --export MANWIDTH (math "min($MANWIDTH, $(tput cols))")
    __fish_man --no-justification $argv
end
