# This is the shared user configuration applied and customised by each
# host's `robert` user.
{
  pkgs,
  perSystem,
  system,
  inputs,
  lib,
  config,
  flake,
  ...
}:
let
  steelWithLsp = perSystem.steel.default.overrideAttrs (oldAttrs: {
    cargoBuildFlags = "-p cargo-steel-lib -p steel-interpreter -p steel-language-server";
  });
in
{
  imports = [
    inputs.self.homeModules.my-config
    inputs.self.homeModules.my-programs-fish
    ./darwin.nix
  ];

  home.packages = [
    perSystem.helix.helix
    perSystem.helix.helix-cogs
    perSystem.self.schemat
    pkgs.curl
    pkgs.direnv
    pkgs.eza
    pkgs.fd
    pkgs.fish
    pkgs.fish-lsp
    pkgs.fzf
    pkgs.git
    pkgs.git-open
    pkgs.gum
    pkgs.home-manager
    pkgs.jq
    pkgs.jujutsu
    pkgs.just
    pkgs.lazygit
    pkgs.neovim
    pkgs.nix-direnv
    pkgs.nix-output-monitor
    pkgs.nixfmt-rfc-style
    pkgs.nushell
    pkgs.ripgrep
    pkgs.tealdeer
    pkgs.tmux
    pkgs.tree
    pkgs.vim
    pkgs.wget
    pkgs.zoxide
    steelWithLsp

    # Fonts
    pkgs.nerd-fonts.roboto-mono
  ];

  fonts.fontconfig.enable = !pkgs.stdenv.isDarwin;

  my.config.force = true;
  my.config.source = {
    ".config/ghostty/config" = "config/ghostty/config";
    ".config/ghostty/macos-config" = lib.mkIf pkgs.stdenv.isDarwin "config/ghostty/macos-config";
    ".config/ghostty/linux-config" = lib.mkIf pkgs.stdenv.isLinux "config/ghostty/linux-config";

    ".config/kitty" = "config/kitty";
    ".config/helix" = "config/helix";
    ".config/tmux" = "config/tmux";
    ".config/git" = "config/git";
    ".config/zed" = "config/zed";
    ".config/fish" = "config/fish";
    ".config/direnv/direnv.toml" = "config/direnv/direnv.toml";
    ".zshenv" = "config/zsh/home_zshenv";
    ".config/zsh" = "config/zsh";
  };

  # This needs to be in a known location so it can be sourced regardless
  # of whether we're in standalone HM or as a system module.
  home.file.".local/share/zsh/hm-session-vars.sh".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  # Since hm-session-vars is consistent and will be sourced, ZDOTDIR can
  # be set declaratively and will be used by ZSH during init.
  home.sessionVariables.ZDOTDIR = "$HOME/.config/zsh";

  # Ordinarily, the direnv module would set this automatically.
  home.file.".config/direnv/lib/nix-direnv.sh".source =
    "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

  # My change to helix-cogs generates a 'steel-language-server' directory,
  # and since steel doesn't care if the directories are nested, it's possible
  # to use it directly. Using recursive in case I want to add any modules
  # manually later on.
  home.file.".local/share/steel" = {
    source = perSystem.helix.helix-cogs;
    recursive = true;
  };
  home.sessionVariables.STEEL_HOME = "$HOME/.local/share/steel";
  home.sessionVariables.STEEL_LSP_HOME = "$HOME/.local/share/steel/steel-language-server";

  my.programs.fish.plugins = [
    (pkgs.fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "44c521ab292f0eb659a9e2e1b6f83f5f0595fcbd"; # as of 2025-01-01
      hash = "sha256-85iU1QzcZmZYGhK30/ZaKwJNLTsx+j3w6St8bFiQWxc=";
    })
  ];
  home.sessionVariables.NIX_CONFIG_REV = flake.rev or flake.dirtyRev;

  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    blueprint.flake = inputs.blueprint;
    home-manager.flake = inputs.home-manager;
    nix-darwin.flake = inputs.nix-darwin;
    helix.flake = inputs.helix;
  };
  nix.settings.log-lines = 25;
}
