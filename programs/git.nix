{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.programs.git;
in
{
  options.my.programs.git = {
    enable = mkEnableOption "my git configuration";
  };

  config = mkIf cfg.enable {
    home.file.".config/git".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/nix-dotfiles/config/git";
    home.packages = [ pkgs.git ];
  };
}
