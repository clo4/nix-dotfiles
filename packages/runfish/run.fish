set pre_functions (functions --names)

set -l dir (pwd)
while test "$dir" != /
    if test -e "$dir/run.fish"
        source "$dir/run.fish"
        break
    end
    set dir (dirname "$dir")
end

if test "$dir" = /
    echo "Error: run.fish not found in current or parent directories"
    exit 1
end

set post_functions (functions --names)

set new_functions
for function in $post_functions
    if not contains -- $function $pre_functions; and not string match '_*' -- $function
        set --append new_functions $function
    end
end

if not set -q argv[1]
    for function in $new_functions
        echo -- $function
    end
else if contains -- $argv[1] $new_functions
    $argv
else
    echo "did not match a function name: $argv[1]"
end
