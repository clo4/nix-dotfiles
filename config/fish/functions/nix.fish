function nix --wraps nix
    if status is-interactive
        and test (count $argv) -gt 0
        and not contains -- --command $argv
        and not contains -- -c $argv
        and not contains -- --help $argv
        switch $argv[1]
            case develop
                announce nix develop $argv[2..] --command (status fish-path)
            case shell
                # eelco has stated that IN_NIX_SHELL will not be added to 'nix shell'
                # because its behavior differs from 'nix-shell' and 'nix develop', but
                # from a user's perspective, I'm still entering a subshell launched by
                # Nix, so I want to know about that.
                # Nix sets IN_NIX_SHELL to either 'pure' or 'impure'. I'm using an
                # alternative that differentiates it while still setting it.
                IN_NIX_SHELL=shell announce nix shell $argv[2..] --command (status fish-path)
            case '*'
                command nix $argv
        end
    else
        command nix $argv
    end
end
