{
  pkgs,
  flake,
  config,
  inputs,
  ...
}:
{
  imports = [
    "${flake}/users/robert/work-configuration.nix"
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

  my.config.source = {
    ".config/zed" = "config/zed/hosts/pc3";
  };
}
