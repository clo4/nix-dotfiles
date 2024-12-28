{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.programs.ghostty;
in
{
  options = {
    my.programs.ghostty.enable = mkEnableOption "my Ghostty config";
  };

  config = mkIf cfg.enable {
    home.file.".config/ghostty/config".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/nix-dotfiles/config/ghostty/config";
    home.file.".config/ghostty/macos-config".source = lib.mkIf pkgs.stdenv.isDarwin (
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/nix-dotfiles/config/ghostty/macos-config"
    );
  };
}
