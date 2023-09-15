{
  pkgs,
  osConfig,
  inputs,
  ...
}: let
  language = name: text: text;
in {
  imports = [
    ../home.nix
  ];

  home.homeDirectory = "/Users/robert";
  home.stateVersion = "23.05";

  # Interestingly this is actually broken in macOS! I went on a deep-dive
  # and eventually found that the Zed team has run into this issue as well.
  # https://github.com/zed-industries/community/issues/1373#issuecomment-1499033975
  home.file.".hushlogin".text = "";

  programConfig.hammerspoon = {
    enable = true;
    init = language "lua" ''
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

  # Might move this to the fish module one day but for now it's specific to
  # this system. If there's another Mac or a NixOS system to care about, that
  # would be a good time to refactor into something that can be shared.
  programs.fish.interactiveShellInit = language "fish" ''
    # 1Password SSH agent should only be used if not in an SSH session
    if not set -q SSH_TTY
      set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    end
  '';

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
      cursor_blink_interval = -1;
      mouse_hide_wait = 0;
      strip_trailing_spaces = "always";
    };
  };
}
