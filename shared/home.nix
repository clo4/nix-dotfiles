{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../programs
    ../modules/home
  ];

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
    comma
    amber
    sad
    delta

    # File stuff
    eza
    jq
    jnv
    glow

    # File transfer stuff
    curl
    croc
    wget

    # Other stuff
    git-open
    asciinema
    parallel
    _1password

    # ccase is used for case conversion
    inputs.ccase.packages.${pkgs.stdenv.system}.default
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
    home-manager.enable = true;

    broot = {
      enable = true;
      settings = {
        imports = ["skins/dark-gruvbox.hjson"];
        # NOTE: In Ghostty, this breaks shift. Not sure why and haven't looked into it.
        # enable_kitty_keyboard = lib.mkForce true;
      };
    };

    jujutsu.enable = true;

    # TODO: figure out why this is breaking in nushell
    zoxide = {
      enable = true;
      enableNushellIntegration = false;
    };

    zellij.enable = true;

    nushell = {
      enable = true;
    };

    fzf = {
      enable = true;
      defaultOptions = [
        # "--height ~40%"
      ];
    };

    gh = {
      enable = true;

      # Required because of a settings migration
      settings.version = 1;
    };

    bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };
  };
}
