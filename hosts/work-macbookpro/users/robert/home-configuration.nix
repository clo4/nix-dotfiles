{
  flake,
  config,
  ...
}:
{
  home.stateVersion = "24.11";

  imports = [ "${flake}/users/robert/home-configuration.nix" ];

  my.config.directory = "${config.home.homeDirectory}/Developer/clo4/nix-dotfiles";

  home.sessionVariables = {
    # My fish configuration uses this to check whether it should check if
    # the Touch ID PAM module is enabled. See: config/fish/functions/fish_greeting.fish
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
  };
}
