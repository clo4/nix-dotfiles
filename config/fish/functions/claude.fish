function claude
    nix shell nixpkgs#nodejs_latest -c npx -y @anthropic-ai/claude-code -- $argv
end
