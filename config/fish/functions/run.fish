# There are an annoying amount of steps required for proper isolation
# since this function is initially executed in our current environment.
# When 'run.fish' is found, it needs to be executed in its own fish
# (and you can't rely on fish being in $PATH because this function is
# used for bootstrapping).
# Constraints:
# - Fish syntax is too complicated to reasonably grep function definitions
# - Don't want to execute twice
# Which means the script *has* to be sourced to bring its functions into
# the local scope.
# If it were just sourced normally, it would have access to local variables
# such as pre_functions, which is undesirable, so it has to be sourced
# from a different function with no locals.
# All the functions defined will be in scope for 'run.fish' too, which
# means a name collision would be possible. The functions names have to be
# prefixed to avoid this.
# Two extra requirements: 1) must preserve exit status, 2) executes in same
# directory as the file.

function run
    # 'test' is unable to test for '-h' because it sees it as a flag.
    switch $argv[1]
        case -h --help
            echo "Usage: run [function [args...]]

Run fish functions defined in a single file. It's a command runner,
similar to just, but you get use the best shell scripting language.

Create a file named 'run.fish' and write some functions in it.
Invoking 'run' will source the file in an isolated fish environment
and invoke whichever function was named.

Run 'run' without any arguments to get a list of public functions.
Function names beginning with an underscore are private.

The script itself, and all functions, will be invoked from the
directory containing the file. All output from the top level of the
script will be silenced, functions will not be."
            return
    end

    set -l dir (pwd)
    set -l file_path
    while test "$dir" != /
        if test -e "$dir/run.fish"
            set file_path "$dir/run.fish"
            break
        end
        set dir (dirname "$dir")
    end

    if not set -q file_path[1]
        echo (set_color brred)"error:"(set_color normal)" run.fish not found in current or parent directories"
        return 1
    end

    set -l fish_path (status fish-path)

    $fish_path --no-config -c '
    function __private_main
        set -l pre_functions (functions --names)

        cd '$dir'
        # The script could cd to a different directory before the function
        # is invoked.
        __private_source '$file_path' &>/dev/null
        cd '$dir'

        set -l post_functions (functions --names)

        set -l new_functions
        for function in $post_functions
            if not contains -- $function $pre_functions; and not string match \'_*\' -- $function
                set --append new_functions $function
            end
        end

        if not set -q argv[1]
            if test "$__COMPLETE_RUN_DESCRIPTIONS" != 1
                for function in $new_functions
                    echo -- $function
                end
            else
                for function in $new_functions
                    set desc (functions -vD $function | sed -n -e "5{p;q}")
                    echo -- $function\\t$desc
                end
            end
        else if contains -- $argv[1] $new_functions
            $argv
            return $status
        else
            echo (set_color brred)"error:"(set_color normal)" did not match a function name: $argv[1]"
        end
    end
    function __private_source
        source $argv
    end
    __private_main $argv
    ' $argv
    set -l result_status $status

    return $result_status
end
