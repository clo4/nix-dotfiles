{
  pkgs,
  osConfig,
  inputs,
  ...
}: {
  imports = [
    ../common.nix
  ];

  home.homeDirectory = "/Users/robert";
  home.stateVersion = "23.05";

  home.file.".hushlogin".text = "";

  # If I install more spoons or make my own I should make this a module.
  # For now this is okay as a one-off thing.
  home.file.".hammerspoon/init.lua".text = ''
    local SkyRocket = hs.loadSpoon("SkyRocket")
    sky = SkyRocket:new({
      opacity = 0.4,
      moveModifiers = {'cmd', 'ctrl'},
      moveMouseButton = 'left',
      resizeModifiers = {'cmd', 'ctrl'},
      resizeMouseButton = 'other',
    })
  '';
  home.file.".hammerspoon/Spoons/SkyRocket.spoon".source = inputs.skyrocket-spoon;

  # If the system should have Touch ID enabled for sudo, also enable the check
  # in my fish config. It runs every time a new shell starts, but this is a
  # pretty cheap check because the file it checks is small.
  my.programs.fish.enableGreetingTouchIdCheck = osConfig.security.pam.enableSudoTouchIdAuth;

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
