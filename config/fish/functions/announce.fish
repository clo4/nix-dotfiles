function announce
    set colored_command (echo -- "$argv" | fish_indent --ansi)
    echo "$(set_color magenta)~~>$(set_color normal) $colored_command"
    $argv
end
