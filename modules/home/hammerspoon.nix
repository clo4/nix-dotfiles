{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programConfig.hammerspoon;

  configLocation = ".hammerspoon";
in {
  options = {
    programConfig.hammerspoon = {
      enable = mkEnableOption "hammerspoon configuration";

      init = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Lua init script
        '';
      };

      spoons = mkOption {
        type = with types; attrsOf path;
        default = {};
        description = ''
          Spoons to install.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.init != "") {
      home.file."${configLocation}/init.lua".text = cfg.init;
    })
    (mkIf (cfg.spoons != {}) {
      home.file =
        foldl' (a: b: a // b) {}
        (mapAttrsToList
          (name: path: {
            "${configLocation}/Spoons/${name}.spoon".source = path;
          })
          cfg.spoons);
    })
  ]);
}
