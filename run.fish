function _validate_system_verb
    set verbs build switch
    set joined_verbs (string join ', ' -- $verbs)

    if not set -q argv[1]
        echo "error: expected at least one of: $joined_verbs"
        exit 1
    end
    switch $argv[1]
        case $verbs
            return 0
        case '*'
            echo "error: verb '$argv[1]' must be one of: $joined_verbs"
            exit 1
    end
end

function homeserver1 -d "Build and switch homeserver1 NixOS configuration"
    _validate_system_verb $argv

    nixos-rebuild $argv[1] \
        --flake .#homeserver1 \
        --target-host robert@homeserver1 \
        --build-host robert@homeserver1 \
        --fast \
        --use-remote-sudo \
        $argv[2..]
end
alias hs homeserver1

function macmini -d "Build and switch macmini nix-darwin configuration"
    _validate_system_verb $argv

    darwin-rebuild $argv[1] --flake .#macmini --max-jobs 8 $argv[2..]
end
alias mm macmini

function macbook-air -d "Build and switch robert@macbook-air Home Manager configuration"
    _validate_system_verb $argv

    home-manager $argv[1] --flake .#robert@macbook-air --max-jobs 8 $argv[2..]
end
alias mb macbook-air

function rcon -d "Connect to homeserver1 and begin an interactive RCON session"
    echo (set_color --italics)"connecting to homeserver1 and executing rcon-cli..."(set_color normal)
    ssh robert@homeserver1 "sudo podman exec -i minecraft-family rcon-cli"
end
