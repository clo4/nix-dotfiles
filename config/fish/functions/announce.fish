function announce
    set colored_command (string escape -- $argv | string join ' ' | fish_indent --ansi)
    echo "$(set_color magenta)~~>$(set_color normal) $colored_command"
    $argv
end
