{
  pkgs,
  flake,
  config,
  inputs,
  ...
}:
{
  imports = [
    "${flake}/users/robert/home-configuration.nix"
    inputs.agenix.homeManagerModules.default
  ];

  home.stateVersion = "25.05";

  # Config fails to build without this.
  nix.package = pkgs.nix;

  my.config.directory = "${config.home.homeDirectory}/Repos/nix-dotfiles";

  age.secrets.work-gitconfig = {
    file = ./gitconfig.age;
    path = "$HOME/Repos/Work/.gitconfig";
  };

  my.programs.fish.plugins = [
    (pkgs.fetchFromGitHub {
      owner = "jorgebucaran";
      repo = "nvm.fish";
      rev = "846f1f20b2d1d0a99e344f250493c41a450f9448"; # current as of 2025-11-18
      hash = "sha256-u3qhoYBDZ0zBHbD+arDxLMM8XoLQlNI+S84wnM3nDzg=";
    })
  ];

  home.packages = [
    pkgs.awscli2
    pkgs.python3
    pkgs.vtsls
    pkgs.typos
    pkgs.typos-lsp
    pkgs.mkcert

    # Useful for quick scripts and the REPL
    pkgs.deno
  ];
}
