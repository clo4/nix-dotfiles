{...}: {
  imports = [
    ../common.nix
  ];

  home.homeDirectory = "/home/robert";

  my.programs.fish.enableWslFunctions = true;
}
