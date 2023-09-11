# The home/<user>/default.nix file configures the user's home directory,
# but only the stuff that's truly common between all systems. This may
# not end up being that much stuff!
#
# All system-specific user configuration is done in the other files in
# this directory.
#
# This file isn't responsible for importing the home-manager module, that's
# assumed to already be imported. The reason for this is sharing the same
# common home configuration between NixOS and macOS (with nix-darwin).
{pkgs, ...}: {
  imports = [
    ../programs
    ../modules/home
  ];

  home.stateVersion = "23.05";

  # The homeDirectory is configured by each host's configuration because it's
  # not constant between linux and macos
  home.username = "robert";

  home.packages = with pkgs; [
    # Editors that I sometimes want to play with
    vim
    neovim

    # Find me stuff
    fd
    ripgrep
    fzf
    comma

    # File stuff
    eza
    jq
    bat
    frogmouth
    glow

    # File transfer stuff
    curl
    croc
    wget

    # Other stuff
    git-open
    asciinema
  ];

  # Enables the programs and uses my configuration for them.
  # The options are defined in /programs/*
  my.programs = {
    fish.enable = true;
    git.enable = true;
    tmux.enable = true;
    helix.enable = true;
    tealdeer.enable = true;
  };

  # Enables programs that I don't have a more complicated config for.
  # Programs in this section should be limited to a few lines of config at most.
  programs = {
    broot.enable = true;
    zoxide.enable = true;
    home-manager.enable = true;
    zellij.enable = true;
    nushell.enable = true;
    gh.enable = true;
  };
}