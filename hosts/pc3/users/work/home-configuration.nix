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

  home.packages = [
    pkgs.awscli2
    pkgs.python3
    pkgs.vtsls
    pkgs.typos
    pkgs.typos-lsp

    # Useful for quick scripts and the REPL
    pkgs.deno
  ];
}
