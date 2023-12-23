{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.ghostty;
in {
  options = {
    my.programs.ghostty.enable = mkEnableOption "my Ghostty config";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      settings = {
        unfocused-split-opacity = 0.85;
        unfocused-split-fill = "#000000";
        cursor-style-blink = false;
        mouse-hide-while-typing = true;

        quit-after-last-window-closed = true;

        macos-option-as-alt = true;
        window-theme = "dark";

        font-family = "JetBrainsMonoNL Nerd Font Mono";
        font-size = 12;

        window-height = 60;
        window-width = 170;

        theme = "GruvboxDark";

        # Disables most ligatures entirely, keeping this around in case I ever change fonts
        # font-feature = ["-liga" "-dlig" "-calt"];
      };

      keybindings = {
        "super+left" = "goto_split:left";
        "super+right" = "goto_split:right";
        "super+up" = "goto_split:top";
        "super+down" = "goto_split:bottom";

        "page_up" = "scroll_page_fractional:-0.5";
        "page_down" = "scroll_page_fractional:0.5";
      };
    }
  };
}
