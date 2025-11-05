# This is the shared user configuration applied and customised by each
# host's `robert` user.
{
  pkgs,
  pkgs',
  perSystem,
  inputs,
  config,
  flake,
  ...
}@args:
let
  steelWithLsp = perSystem.steel.default.overrideAttrs (oldAttrs: {
    cargoBuildFlags = "-p cargo-steel-lib -p steel-interpreter -p steel-language-server";
  });

  neovimWithDependencies = pkgs.symlinkJoin {
    name = "neovim-with-dependencies";
    paths = [ pkgs.neovim ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${
          pkgs.lib.makeBinPath [
            pkgs.curl
            pkgs.tree-sitter
            pkgs.ripgrep
          ]
        }
    '';
  };
in
{
  imports = [
    inputs.self.homeModules.my-config
    inputs.self.homeModules.my-programs-fish
    inputs.self.homeModules.my-programs-neovim
    inputs.self.modules.common.nixpkgs-unstable
    ./darwin.nix

    "${flake}/config/nvim/plugins.nix"
  ];

  home.packages = [
    perSystem.helix.helix
    # perSystem.helix.helix-cogs
    # steelWithLsp
    perSystem.self.schemat
    perSystem.self.ccase # Case conversion used in my Helix keybindings (TODO: port to scheme plugin?)
    pkgs.curl
    pkgs'.stripe-cli
    pkgs.gh
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
    neovimWithDependencies
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

    # Fonts
    pkgs.nerd-fonts.roboto-mono
  ];

  fonts.fontconfig.enable = !pkgs.stdenv.isDarwin;

  my.config.source =
    let
      # Some tools prefer to place their configuration in the correct directory
      # for the platform. On Linux, that's XDG_CONFIG_HOME, which defaults to
      # ~/.config if unset. On macOS, the configuration directory is
      # '~/Library/Application Support'.
      # Unfortunately, this isn't common - most tools simply use ~/.config
      # regardless of platform conventions.
      platformConfig = if pkgs.stdenv.isDarwin then "Library/Application Support" else ".config";
    in
    {
      ".config/ghostty/config" = "config/ghostty/config";
      ".config/ghostty/os-config" =
        if pkgs.stdenv.isDarwin then
          "config/ghostty/os-config-darwin"
        else
          "config/ghostty/os-config-linux";

      ".config/kitty" = "config/kitty";

      ".config/helix" = "config/helix";

      ".config/nvim" = "config/nvim";

      ".config/tmux" = "config/tmux";

      ".config/git" = "config/git";
      "${platformConfig}/jj" = "config/jj";

      ".config/zed" = "config/zed";
      ".config/direnv/direnv.toml" = "config/direnv/direnv.toml";

      # Fish can't just link the config directory because if the flake directory
      # is used as my.config.directory (which is only true on new home manager
      # systems during bootstrapping) then it will try to write to the fish_variables
      # file repeatedly and fail each time, spamming the terminal with errors.
      # It's better to link each of the directories individually to avoid this.
      ".config/fish/conf.d" = "config/fish/conf.d";
      ".config/fish/functions" = "config/fish/functions";
      ".config/fish/completions" = "config/fish/completions";
      ".config/fish/config.fish" = "config/fish/config.fish";

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

  # # My change to helix-cogs generates a 'steel-language-server' directory,
  # # and since steel doesn't care if the directories are nested, it's possible
  # # to use it directly.
  # home.file.".local/share/steel".source = perSystem.helix.helix-cogs;
  # home.sessionVariables.STEEL_HOME = "$HOME/.local/share/steel";
  # home.sessionVariables.STEEL_LSP_HOME = "$HOME/.local/share/steel/steel-language-server";

  my.programs.fish.plugins = [
    (pkgs.fetchFromGitHub {
      owner = "IlanCosman";
      repo = "tide";
      rev = "44c521ab292f0eb659a9e2e1b6f83f5f0595fcbd"; # as of 2025-01-01
      hash = "sha256-85iU1QzcZmZYGhK30/ZaKwJNLTsx+j3w6St8bFiQWxc=";
    })
    # (pkgs.fetchFromGitHub {
    #   owner = "jorgebucaran";
    #   repo = "nvm.fish";
    #   rev = "846f1f20b2d1d0a99e344f250493c41a450f9448"; # as of 2025-01-01
    #   hash = "sha256-u3qhoYBDZ0zBHbD+arDxLMM8XoLQlNI+S84wnM3nDzg=";
    # })
  ];
  home.sessionVariables.NIX_CONFIG_REV = flake.rev or flake.dirtyRev;
  home.sessionVariables.NIX_CONFIG_DIR = config.my.config.directory;
  home.sessionVariables.NIX_CONFIG_LAST_MODIFIED = builtins.toString flake.lastModified;

  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
    nixpkgs-unstable.flake = inputs.nixpkgs-unstable;
    blueprint.flake = inputs.blueprint;
    home-manager.flake = inputs.home-manager;
    nix-darwin.flake = inputs.nix-darwin;
    helix.flake = inputs.helix;
  };
  nix.settings.log-lines = 25;
}
