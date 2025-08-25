function shell
    NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#$argv
end
