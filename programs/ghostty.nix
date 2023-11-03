{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programs.ghostty;
in {
  options = {
    my.programs.ghostty.enable = mkEnableOption "my Ghostty config";
  };

  config = mkIf cfg.enable {
    programs.ghostty.enable = true;

    programs.ghostty.settings = {
      unfocused-split-opacity = 0.96;
      cursor-style-blink = false;
      mouse-hide-while-typing = true;

      macos-option-as-alt = true;
      window-theme = "dark";

      font-family = "JetBrainsMonoNL Nerd Font Mono";
      font-size = 12;

      window-height = 50;
      window-width = 160;

      # Disables most ligatures entirely, keeping this around in case I ever change fonts
      # font-feature = ["-liga" "-dlig" "-calt"];

      config-file = [
        (inputs.iTerm2-color-schemes + "/ghostty/GruvboxDark")
      ];
    };

    programs.ghostty.keybindings = {
      "super+left" = "goto_split:left";
      "super+right" = "goto_split:right";
      "super+up" = "goto_split:top";
      "super+down" = "goto_split:bottom";
    };
  };
}
