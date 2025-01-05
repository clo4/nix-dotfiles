{
  pkgs,
  perSystem,
  system,
  inputs,
  lib,
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
  ];

  home.packages = [
    perSystem.helix.helix
    perSystem.helix.helix-cogs
    perSystem.self.schemat
    pkgs.curl
    pkgs.direnv
    pkgs.eza
    pkgs.fd
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
    pkgs.vim
    pkgs.wget
    pkgs.zoxide
    steelWithLsp
  ];

  my.config.force = true;
  my.config.source = {
    ".config/ghostty/config" = "ghostty/config";
    ".config/ghostty/macos-config" = lib.mkIf pkgs.stdenv.isDarwin "ghostty/macos-config";
    ".config/ghostty/linux-config" = lib.mkIf pkgs.stdenv.isLinux "ghostty/linux-config";
    ".config/kitty" = "kitty";
    ".config/helix" = "helix";
    ".config/tmux" = "tmux";
    ".config/git" = "git";
    ".config/zed" = "zed";
    ".config/fish" = "fish";
    ".config/direnv/direnv.toml" = "direnv/direnv.toml";
    ".zshenv" = "zsh/home_zshenv";
    ".config/zsh" = "zsh";
  };
  home.file.".config/direnv/lib/nix-direnv.sh".source =
    "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";

  home.file.".hushlogin".source = lib.mkIf pkgs.stdenv.isDarwin pkgs.emptyFile;

  home.sessionVariables.STEEL_HOME = "$HOME/.local/share/steel";
  home.sessionVariables.STEEL_LSP_HOME = "$HOME/.local/share/steel/steel-language-server";
  home.file.".local/share/steel" = {
    source = perSystem.helix.helix-cogs;
    recursive = true;
  };

  my.programs.fish.plugins = [
    (pkgs.fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "44c521ab292f0eb659a9e2e1b6f83f5f0595fcbd"; # as of 2025-01-01
      hash = "sha256-85iU1QzcZmZYGhK30/ZaKwJNLTsx+j3w6St8bFiQWxc=";
    })
  ];
}
