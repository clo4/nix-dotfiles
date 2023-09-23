{
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programConfig.ghostty;
in {
  options = {
    my.programConfig.ghostty.enable = mkEnableOption "my Ghostty config";
  };

  config = mkIf cfg.enable {
    programConfig.ghostty.enable = true;

    programConfig.ghostty.settings = {
      unfocused-split-opacity = 0.96;
      cursor-style-blink = false;
      mouse-hide-while-typing = true;

      macos-option-as-alt = true;
      window-theme = "dark";

      font-family = "JetBrainsMono Nerd Font";

      config-file = [
        (inputs.iTerm2-color-schemes + "/ghostty/GruvboxDark")
      ];
    };

    programConfig.ghostty.keybindings = {
      "super+left" = "goto_split:left";
      "super+right" = "goto_split:right";
      "super+up" = "goto_split:top";
      "super+down" = "goto_split:bottom";

      # This is slightly more ergonomic for me, because on my keyboard layout,
      # super is right next to control.
      "super+ctrl+d" = "new_split:down";
    };
  };
}
