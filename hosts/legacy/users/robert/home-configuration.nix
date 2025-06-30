{
  pkgs,
  flake,
  config,
  ...
}:
{
  imports = [ "${flake}/users/robert/home-configuration.nix" ];

  home.stateVersion = "25.05";

  # Config fails to build without this.
  nix.package = pkgs.nix;

  my.config.directory = "${config.home.homeDirectory}/Developer/clo4/nix-dotfiles";
}
