{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.programConfig.zed;
in
{
  options = {
    my.programConfig.zed.enable = mkEnableOption "my Zed config";
  };
  config = mkIf cfg.enable {
    home.file.".config/zed".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/nix-dotfiles/config/zed";
  };
}
