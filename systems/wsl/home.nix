{...}: {
  imports = [
    ../home.nix
  ];

  home.homeDirectory = "/home/robert";

  home.stateVersion = "23.05";

  my.programs.fish.enableWslFunctions = true;
}
