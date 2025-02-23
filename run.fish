function switch-server
    nixos-rebuild switch \
        --flake .#homeserver1 \
        --target-host robert@homeserver1 \
        --build-host robert@homeserver1 \
        --fast \
        --use-remote-sudo \
        $argv
end

function switch-macmini
    darwin-rebuild switch --flake .#macmini --max-jobs 8 &| nom
end

function switch-macbook-air
    home-manager switch --flake .#macbook-air --max-jobs 8 &| nom
end
