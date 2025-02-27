function switch-server -d "Build and switch homeserver1 NixOS configuration"
    nixos-rebuild switch \
        --flake .#homeserver1 \
        --target-host robert@homeserver1 \
        --build-host robert@homeserver1 \
        --fast \
        --use-remote-sudo \
        $argv
end

function switch-macmini -d "Build and switch macmini nix-darwin configuration"
    darwin-rebuild switch --flake .#macmini --max-jobs 8 $argv
end

function switch-macbook-air -d "Build and switch robert@macbook-air Home Manager configuration"
    home-manager switch --flake .#robert@macbook-air --max-jobs 8 $argv
end
