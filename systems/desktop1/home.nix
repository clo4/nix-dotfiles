{osConfig, ...}: let
  language = name: text: text;
in {
  imports = [
    ../../shared/home.nix
  ];

  home.homeDirectory = "/home/robert";
  home.stateVersion = "24.05";

  home.file.".hushlogin".text = "";

  nixpkgs.config.allowUnfree = true;

  # This is under programs because it does technically install kitty, but that's
  # an implementation detail, I use the kitty installed with brew. I just didn't
  # want to bother copying the module to my own modules folder just to remove
  # one line from it.
  my.programs.kitty.enable = true;

  my.programs.ghostty.enable = false;
  # my.programConfig.zed.enable = true;
}
