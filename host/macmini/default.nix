{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ../common.nix
    ./brew.nix
  ];

  # This has to be set on macOS to make fish a usable shell
  environment.shells = [pkgs.fish];

  users.users.robert = {
    description = "Robert";
    home = "/Users/robert";
    shell = pkgs.fish;
  };

  # This needs to be reapplied after system updates
  security.pam.enableSudoTouchIdAuth = true;

  networking.hostName = "macmini";

  # Hides desktop icons (but they're still accessible through Finder)
  system.defaults.finder.CreateDesktop = false;

  # TODO: Should this be moved to the common config?
  services.nix-daemon.enable = true;

  # Context: https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
  programs.fish.loginShellInit = let
    # If there's ever a double quote in a path, something has obviously gone
    # very, very wrong.
    dquote = str: "\"" + str + "\"";
    makeBinPathList = map (path: path + "/bin");
  in ''
    fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
    set fish_user_paths $fish_user_paths
  '';

  system.stateVersion = 4;
}
