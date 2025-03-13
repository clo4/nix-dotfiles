# @fish-lsp-disable 2002 4004

# --- Utility functions

set -g run_depth 0

function _pretty_print
    set -g run_depth (math "$run_depth + 1")
    set stem (string repeat --count $run_depth "~~")

    set colored_command (string escape -- $argv | string join ' ' | fish_indent --ansi)
    echo "$(set_color brgreen --bold)$stem>$(set_color normal) $colored_command"
end

function _run
    _pretty_print $argv
    $argv
end

# --- Commands

set this_host (hostname -s)

function rcon -d "Connect to homeserver1 and begin an interactive RCON session"
    echo (set_color --italics)"connecting to homeserver1 and executing rcon-cli..."(set_color normal)
    _run ssh robert@homeserver1 "sudo podman exec -i minecraft-family rcon-cli"
end

function check-applied -d "Check if the currently applied configuration needs to be updated"
    set last_commit_timestamp (git log -1 --format=%at)
    set current_commit_pretty (set_color --dim --italics)$NIX_CONFIG_REV(set_color normal)
    if test $NIX_CONFIG_LAST_MODIFIED -lt $last_commit_timestamp
        echo "Configuration is out of date."
        echo $current_commit_pretty
        # TODO: Prompt to apply configuration if out of date?
        return 1
    else
        set commit_hash (git log -1 --format=%H)
        if test $NIX_CONFIG_REV = $commit_hash
            echo "Configuration is the most recent commit."
            echo $current_commit_pretty
        else
            echo "Current configuration is dirty (new)."
            echo $current_commit_pretty
        end
    end
end

# --- Functions for building/switching hosts

function homeserver1 -a verb
    set rebuild_args $verb --flake .#homeserver1
    if test $this_host != homeserver1
        set --append rebuild_args --fast --use-remote-sudo --target-host robert@homeserver1 --build-host robert@homeserver1
    end
    set --append rebuild_args $argv[2..]
    _run nixos-rebuild $rebuild_args
end

function macmini -a verb
    _run darwin-rebuild $verb --flake .#macmini --max-jobs 8 $argv[2..]
end

function macbook-air -a verb
    _run home-manager $verb --flake ".#$USER@macbook-air" --max-jobs 8 $argv[2..]
end

# The logic below defines the commands used to build/switch configurations for
# the hosts above. This requires some amount of metaprogramming, which Fish has
# decent support for.

set hosts (ls hosts)
set verbs build switch

for host in $hosts
    functions -q $host; or continue

    functions --copy $host _$host
    functions --erase $host

    for verb in $verbs
        echo "
function $host-$verb -d '$verb the configuration for $host'
    _$host $verb \$argv
end
        " | source
        test $this_host = $host; and alias host-$verb $host-$verb
    end
end
