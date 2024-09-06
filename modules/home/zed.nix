{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programConfig.zed;
  jsonFormat = pkgs.formats.json { };
in
{
  options = {
    programConfig.zed.enable = mkEnableOption "zed configuration";
    programConfig.zed.settings = mkOption {
      type = jsonFormat.type;
      default = { };
      example = literalExpression ''
        {
          features.copilot = false;
          theme = "Gruvbox Dark";
        }
      '';
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/zed/settings.json`.
      '';
    };
    programConfig.zed.keymap = mkOption {
      type = jsonFormat.type;
      default = [ ];
      example = literalExpression ''
        []
      '';
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/zed/keymap.json`.
      '';
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "zed/settings.json".source = jsonFormat.generate "zed-settings" cfg.settings;
      "zed/keymap.json".source = jsonFormat.generate "zed-keymap" cfg.keymap;
    };
  };
}
