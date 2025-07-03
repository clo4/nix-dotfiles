{
  flake,
  config,
  ...
}:
{
  home.stateVersion = "24.11";

  imports = [ "${flake}/users/robert/home-configuration.nix" ];

  my.config.directory = "${config.home.homeDirectory}/Developer/clo4/nix-dotfiles";
}
