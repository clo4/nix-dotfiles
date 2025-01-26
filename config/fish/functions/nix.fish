function nix --wraps nix
    if status is-interactive
        and test (count $argv) -gt 0
        and not contains -- --command $argv
        and not contains -- -c $argv
        and not contains -- --help $argv
        switch $argv[1]
            case develop
                announce nix develop --command (status fish-path) $argv[2..]
            case shell
                announce nix shell $argv[2..] --command (status fish-path)
            case '*'
                command nix $argv
            end
    else
        command nix $argv
    end
end
