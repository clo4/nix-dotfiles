{ pkgs, ... }:
{
  imports = [
    ../common.nix
  ];

  home.file.".hushlogin".text = "";

  home.homeDirectory = "/Users/robert";
  home.stateVersion = "23.05";

  programs.kitty = {
    enable = true;
    shellIntegration.mode = "enabled";
    theme = "Gruvbox Dark";
    font.package = pkgs.nerdfonts.override { fonts = ["JetBrainsMono"]; };
    font.name = "JetBrainsMono Nerd Font Mono";
    settings = {
      macos_option_as_alt = true;
      macos_titlebar_color = "dark";
      font_family = "JetBrainsMono Nerd Font Mono";
      tab_bar_style = "fade";
      tab_fade = 1;
      active_tab_font_style = "bold";
      inactive_tab_font_style = "bold";
    };
  };
}
