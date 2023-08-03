{ ... }:
{
  imports = [
    ../common.nix
  ];

  home.file.".hushlogin".text = "";

  home.homeDirectory = "/Users/robert";
  home.stateVersion = "23.05";
}
