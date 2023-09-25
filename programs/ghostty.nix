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

      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

      config-file = [
        (inputs.iTerm2-color-schemes + "/ghostty/GruvboxDark")
      ];
    };

    programs.ghostty.keybindings = {
      # Bound to super+shift for consistency with "zoom split",
      # because that can't be bound to super+enter (default macOS
      # fullscreen keybind)
      # super+shift+d is already vertical split, already consistent
      "super+shift+left" = "goto_split:left";
      "super+shift+right" = "goto_split:right";
      "super+shift+up" = "goto_split:top";
      "super+shift+down" = "goto_split:bottom";
    };
  };
}
