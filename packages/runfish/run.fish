set pre_functions (functions --names)
source run.fish
set post_functions (functions --names)

set new_functions
for function in $post_functions
    if not contains -- $function $pre_functions
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
