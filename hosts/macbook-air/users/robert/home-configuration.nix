{
  inputs,
  pkgs,
  flake,
  ...
}:
{
  imports = [ "${flake}/users/robert/home-configuration.nix" ];

  home.stateVersion = "24.05";

  my.config.directory = ".config/nix-dotfiles";

  # Config fails to build without this.
  nix.package = pkgs.nix;

  # FIXME: This isn't working, need to figure out why
  targets.darwin.currentHostDefaults = {
    NSGlobalDomain = {
      NSUserKeyEquivalents = {
        "\\033Window\\033Zoom" = "@$\\\\U21a9";
      };
    };
  };
}
