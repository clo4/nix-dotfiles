function _run
    set colored_command (string escape -- $argv | string join ' ' | fish_indent --ansi)
    echo "$(set_color brgreen --bold)running: $(set_color normal)$colored_command"
    $argv
end


alias build-homeserver1 "_homeserver1 build"
alias switch-homeserver1 "_homeserver1 switch"
function _homeserver1 -a verb
    set rebuild_args --flake .#homeserver1 --fast --use-remote-sudo $argv[2..]
    if test (hostname -s) != homeserver1
        set --append rebuild_args --target-host robert@homeserver1 --build-host robert@homeserver1
    end
    _run nixos-rebuild $verb $rebuild_args
end


alias build-macmini "_macmini build"
alias switch-macmini "_macmini switch"
function _macmini -a verb
    _run darwin-rebuild $verb --flake .#macmini --max-jobs 8 $argv[2..]
end


alias build-macbook-air "_macbook-air build"
alias switch-macbook-air "_macbook-air switch"
function _macbook-air -a verb
    _run home-manager $verb --flake .#robert@macbook-air --max-jobs 8 $argv[2..]
end


function rcon -d "Connect to homeserver1 and begin an interactive RCON session"
    echo (set_color --italics)"connecting to homeserver1 and executing rcon-cli..."(set_color normal)
    _run ssh robert@homeserver1 "sudo podman exec -i minecraft-family rcon-cli"
end
