{ pkgs, lib, config, ... }:

{
  imports = [
    ../common.nix
    ./brew.nix
  ];

  # This has to be set on macOS to make fish a usable shell
  environment.shells = [ pkgs.fish ];

  # This has to be set explicitly for nix-darwin
  users.users.robert.home = "/Users/robert";

  networking.hostName = "macmini";

  # TODO: Should this be moved to the common config?
  services.nix-daemon.enable = true;

  # Context: https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
  programs.fish.loginShellInit =
    let
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
