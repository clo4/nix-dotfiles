{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.git;
in {
  options.my.programs.git = {
    enable = mkEnableOption "my git configuration";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      userName = "clo4";
      userEmail = "git@clo4.net";
      ignores = [
        "*~"
        "*.swp"
        "result"
        ".DS_Store"
        "/.helix"
        ".flake"
      ];
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
      delta.enable = true;
    };
  };
}
