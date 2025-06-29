# @fish-lsp-disable 2002 4004

# If the devshell isn't active, the functiond defined in this file cannot be
# used, so ensure that the dev environment is always active.
if not set -q IN_NIX_CONFIG_DEVSHELL
    alias devshell "nix develop"
    return 1
end

#
# --- Private utility functions
#

function _pretty_print
    set colored_command (string escape -- $argv | string join ' ' | fish_indent --ansi)
    echo "$(set_color brgreen --bold)~~>$(set_color normal) $colored_command"
end

function _run
    _pretty_print $argv
    $argv
end

#
# --- Commands
#

set -g this_host (hostname -s)

function dry -d "Dry-run a function (replaces _run with _pretty_print)"
    functions --erase _run
    functions --copy _pretty_print _run

    # Mistakenly ran this function without any arguments, print functions.
    if not set -q argv[1]
        run
        return
    end

    $argv
end

function mc-rcon -d "Connect to homeserver1 and begin an interactive RCON session"
    echo (set_color --italics)"connecting to homeserver1 and executing rcon-cli..."(set_color normal)
    _run ssh robert@homeserver1 "sudo podman exec -i minecraft-family rcon-cli"
end

function mc-stop
    echo (set_color --italics)"connecting to homeserver1 and stopping server..."(set_color normal)
    _run ssh robert@homeserver1 "sudo systemctl stop podman-minecraft-family.service"
end

function mc-start
    echo (set_color --italics)"connecting to homeserver1 and stopping server..."(set_color normal)
    _run ssh robert@homeserver1 "sudo systemctl start podman-minecraft-family.service"
end

function mc-logs
    echo (set_color --italics)"connecting to homeserver1 and stopping server..."(set_color normal)
    _run ssh robert@homeserver1 "journalctl -xefu podman-minecraft-family.service"
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

function edit-age -d "Edit the encrypted files stored in this repository"
    set file (fd --type file --glob '*.age' | fzf --height=40% --layout=reverse)
    or return
    agenix -e $file $argv
end

#
# --- Functions for building/switching hosts
#

function homeserver1 -a verb
    set rebuild_args
    set maybe_sudo

    if test $this_host != homeserver1
        # If not building on homeserver1, set homeserver1 to be the target.
        # Otherwise, it is definitely a mistake to switch on the local system.
        set --append rebuild_args --use-remote-sudo --target-host robert@homeserver1
        echo (set_color --dim --italics)"not on homeserver1, targeting remote host..."(set_color normal)

        # If the current system isn't x86-64 Linux, then homeserver1 needs to build
        # its own configuration. --fast (--no-build-nix) is also required because
        # the local system will attempt to execute a version of `nix` that it can't
        # run.
        if test (nix eval --impure --raw --expr 'builtins.currentSystem') != x86_64-linux
            set --append rebuild_args --build-host robert@homeserver1 --fast
            echo (set_color --dim --italics)"not on x86_64-linux, performing remote build..."(set_color normal)
        end

    else
        # If, for whatever reason, we *are* on homeserver1, then we need to use sudo.
        set maybe_sudo sudo
        echo (set_color --dim --italics)"on homeserver1, using sudo..."(set_color normal)
    end

    _run $maybe_sudo nixos-rebuild $verb --flake .#homeserver1 $rebuild_args $argv[2..]
end

function macmini -a verb
    _run sudo darwin-rebuild $verb --flake .#macmini --max-jobs 8 $argv[2..]
end

function macbook-air -a verb
    set jobs 8

    if test $this_host = macbook-air; and pmset -g batt | grep -q "Battery Power"
        echo (set_color --dim --italics)"on battery power, testing connection to macmini..."(set_color normal)
        if timeout 3 nix store info --store ssh-ng://robert@macmini &>/dev/null
            echo (set_color --dim --italics)"delegating to macmini..."(set_color normal)
            set jobs 0
        else
            echo (set_color --dim --italics)"running on this machine..."(set_color normal)
        end
    end

    _run home-manager $verb --flake ".#$USER@macbook-air" --max-jobs $jobs $argv[2..]
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
        echo "function $verb-$host -d '$verb the configuration for $host'; _$host $verb \$argv; end" | source
        test $this_host = $host; and alias $verb-host $verb-$host
    end
end
