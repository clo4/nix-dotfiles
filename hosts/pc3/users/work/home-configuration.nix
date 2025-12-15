{
  pkgs,
  perSystem,
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
    ".config/niri/config.kdl" = "config/niri/config.kdl";
    ".config/niri/common" = "config/niri/common";
    ".config/niri/host" = "config/niri/hosts/pc3";
  };

  age.secrets.niri-private = {
    file = "${flake}/config/niri/private.kdl";
    path = "$HOME/.config/niri/private.kdl";
  };

  home.packages = [
    perSystem.winapps.winapps
    pkgs.systemd-lsp
  ];
}
