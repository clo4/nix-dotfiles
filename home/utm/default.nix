{pkgs, ...}: {
  imports = [
    ../common.nix
  ];

  home.homeDirectory = "/home/robert";

  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    libsForQt5.dolphin
  ];
}
