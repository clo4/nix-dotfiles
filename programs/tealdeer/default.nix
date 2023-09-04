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
    # nixpkgs.overlays = [
    #   (final: prev: {
    #     tealdeer = prev.tealdeer.overrideAttrs (o: {
    #       patches =
    #         (o.patches or [])
    #         ++ [
    #           ./no-max-cache-age.patch
    #         ];
    #     });
    #   })
    # ];
    home.packages = [
      (pkgs.tealdeer.overrideAttrs (o: {
        patches =
          (o.patches or [])
          ++ [
            ./no-max-cache-age.patch
          ];
      }))
    ];
    # programs.tealdeer = {
    #   enable = true;
    # };
    home.file."${cachesDir}/tealdeer/tldr-pages".source = inputs.tldr-pages;
  };
}
