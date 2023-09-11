{
  pkgs,
  osConfig,
  inputs,
  ...
}: {
  imports = [
    ../home.nix
  ];

  home.homeDirectory = "/Users/robert";
  home.stateVersion = "23.05";

  home.file.".hushlogin".text = "";

  # modules/home/hammerspoon.nix
  programConfig.hammerspoon = {
    enable = true;
    init = ''
      local SkyRocket = hs.loadSpoon("SkyRocket")
      sky = SkyRocket:new({
        opacity = 0.4,
        enableMove = false,
        resizeModifiers = {'cmd', 'ctrl'},
        resizeMouseButton = 'right',
      })
    '';
    spoons.SkyRocket = inputs.skyrocket-spoon;
  };

  # If the system should have Touch ID enabled for sudo, also enable the check
  # in my fish config. It runs every time a new shell starts, but this is a
  # pretty cheap check because the file it checks is small.
  my.programs.fish.enableGreetingTouchIdCheck =
    osConfig.security.pam.enableSudoTouchIdAuth;

  programs.kitty = {
    enable = true;
    theme = "Gruvbox Dark";
    font.package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
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
