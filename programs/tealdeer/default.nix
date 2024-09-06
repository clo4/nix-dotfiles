{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programs.tealdeer;
  cachesDir =
    if pkgs.stdenv.isDarwin
    then "Library/Caches"
    else config.xdg.cacheHome;
in {
  options.my.programs.tealdeer = {
    enable = mkEnableOption "my tealdeer configuration";
  };
  config = mkIf cfg.enable {
    # Using a custom patch to override the default maximum cache age, because
    # the tldr-pages cache is managed by Nix which sets the last modified date
    # to 1970.
    # For some reason I couldn't get this to work right with an overlay, so
    # this may cause problems with conflicts in the future... we'll see.
    home.packages = [
      # (pkgs.tealdeer.overrideAttrs (o: {
      #   pname = "tealdeer-patched";
      #   patches =
      #     (o.patches or [])
      #     ++ [
      #       ./no-max-cache-age.patch
      #     ];
      # }))
      pkgs.tealdeer
    ];
    home.file."${cachesDir}/tealdeer/tldr-pages".source = inputs.tldr-pages;
  };
}
