function __source_init
    # Using type instead of command allows for functions too
    if type -q $argv[1]
        $argv | source
    end
end
