{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.kitty;
in {
  options = {
    my.programs.kitty.enable = mkEnableOption "my kitty config";
  };
  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      # Shell integration is enabled by default
      theme = "Gruvbox Dark";
      font.package = pkgs.nerdfonts.override {
        fonts = ["JetBrainsMono"];
      };
      font.name = "JetBrainsMono Nerd Font Mono";
      keybindings = {
      };
      settings = {
        macos_option_as_alt = true;
        macos_titlebar_color = "dark";
        tab_bar_style = "fade";
        tab_fade = 1;
        active_tab_font_style = "bold";
        inactive_tab_font_style = "bold";
        cursor_blink_interval = -1;
        mouse_hide_wait = 3;
        strip_trailing_spaces = "always";
        visual_window_select_characters = "tnseriaogm";

        enabled_layouts = "tall:bias=70;full_size=1";
      };
    };
  };
}
