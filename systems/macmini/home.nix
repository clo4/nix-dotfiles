{
  pkgs,
  osConfig,
  inputs,
  ...
}: let
  language = name: text: text;
in {
  imports = [
    ../../shared/home.nix
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

  # This is under programs because it does technically install kitty, but that's
  # an implementation detail, I use the kitty installed with brew. I just didn't
  # want to bother copying the module to my own modules folder just to remove
  # one line from it.
  my.programs.kitty.enable = true;

  my.programConfig.zed.enable = true;
  my.programConfig.ghostty.enable = true;

  # Might move this to the fish module one day but for now it's specific to
  # this system. If there's another Mac or a NixOS system to care about, that
  # would be a good time to refactor into something that can be shared.
  programs.fish.interactiveShellInit = language "fish" ''
    # 1Password SSH agent should only be used if not in an SSH session
    if not set -q SSH_TTY
      set -gx SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    end
  '';
}
