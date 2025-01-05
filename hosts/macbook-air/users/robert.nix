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

  home.homeDirectory = "/Users/robert";
  home.stateVersion = "24.05";

  my.config.directory = "Developer/nix-dotfiles/config";

  home.file.".hushlogin".text = "";

  # TODO: Since ZSH is the login shell, and it hasn't sourced hm-session-vars,
  # the PATH isn't set up correctly and it can't point to Fish.
  # Additionally, fish is in a different path, so I need a different way to
  # execute it than hardcoding the path in my Ghostty config.
  my.programs.fish.plugins = [
    # (pkgs.fetchFromGitHub {
    #   owner = "lilyball";
    #   repo = "nix-env.fish";
    #   rev = "7b65bd228429e852c8fdfa07601159130a818cfa"; # as of 2025-01-14
    #   hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
    # })
  ];
}
