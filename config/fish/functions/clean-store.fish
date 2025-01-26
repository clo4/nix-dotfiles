function clean-store
    announce nix store gc --verbose
    echo
    announce nix store optimise --verbose
end
