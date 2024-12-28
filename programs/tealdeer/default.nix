{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.programs.tealdeer;
  cachesDir = if pkgs.stdenv.isDarwin then "Library/Caches" else config.xdg.cacheHome;
in
{
  options.my.programs.tealdeer = {
    enable = mkEnableOption "my tealdeer configuration";
  };
  config = mkIf cfg.enable {
    home.packages = [ pkgs.tealdeer ];
    home.file."${cachesDir}/tealdeer/tldr-pages".source = inputs.tldr-pages;
  };
}
