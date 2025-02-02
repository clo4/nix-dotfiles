{ inputs, pkgs, ... }:
{
  imports = [
    inputs.self.homeModules.robert
  ];

  # In my Mac mini configuration, fish is installed globally, so it's
  # not included in my shared user configuration.
  home.packages = [
    pkgs.fish
  ];

  home.stateVersion = "24.05";

  my.config.directory = "Developer/nix-dotfiles/config";

  # FIXME: This may not be working. Figure out why. Does it require logout?
  targets.darwin.currentHostDefaults = {
    NSGlobalDomain = {
      NSUserKeyEquivalents = {
        "\\033Window\\033Zoom" = "@$\\\\U21a9";
      };
    };
  };
}
