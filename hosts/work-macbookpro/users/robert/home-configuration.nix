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
    "${flake}/users/robert/home-configuration.nix"
    inputs.agenix.homeManagerModules.default
  ];

  my.config.directory = "${config.home.homeDirectory}/Developer/clo4/nix-dotfiles";

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

  # The work machine is managed much more imperatively than any of my personal
  # machines, mainly because it isn't worth my time while I'm working to set
  # up Nix correctly (without buy-in from anyone else on the team), and it
  # isn't worth my time when I'm not working because there are other things I'd
  # rather be doing. Instead, I can do as much as is reasonable in Nix, but
  # fall back to plugins and homebrew when stuff doesn't work right.

  home.packages = [
    pkgs.awscli2
    pkgs.python3
    pkgs.serverless
    pkgs.nss_latest
    pkgs.ngrok
    pkgs.vtsls
    pkgs.mongosh
    pkgs.typos
    pkgs.typos-lsp
    pkgs.glow
    pkgs.deno
  ];
}
