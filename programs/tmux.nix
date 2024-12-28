{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.my.programs.tmux;
in
{
  options.my.programs.tmux = {
    enable = mkEnableOption "my tmux configuration";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.tmux ];
    home.file.".config/tmux".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/nix-dotfiles/config/tmux";
  };
}
