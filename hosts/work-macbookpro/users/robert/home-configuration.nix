{
  flake,
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.stateVersion = "24.11";

  imports = [
    "${flake}/users/robert/work-configuration.nix"
    inputs.agenix.homeManagerModules.default
  ];

  my.config.directory = "${config.home.homeDirectory}/Developer/clo4/nix-dotfiles";
  my.config.source = {
    ".config/zed" = "config/zed/hosts/work-macbookpro";
  };

  age.secrets.work-gitconfig = {
    file = ./work-gitconfig.age;
    # This can't be inside my ~/.config/git directory because the entire
    # directory is symlinked non-recursively, and we need to symlink the
    # decrypted copy of this file to this path at login-time.
    path = "$HOME/Developer/Work/.gitconfig";
  };

  home.sessionVariables = {
    FISH_GREETING_CHECK_SUDO_TOUCHID = "1";
  };
}
