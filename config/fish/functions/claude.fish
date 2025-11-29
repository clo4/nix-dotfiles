function claude --wraps claude
    if not command -q node
        announce nix shell nixpkgs#nodejs_latest -c claude -- $argv
    else
        command claude $argv
    end
end
