{...}: {
  imports = [
    ../common.nix
  ];

  home.homeDirectory = "/home/robert";

  users.users.robert = {
    extraGroups = ["wheel" "networkmanager"];
    hashedPassword = "$y$j9T$/DELHBb5Gc.uI/Cyr6KGo1$AgxXRZnEcH74IJnaN.L4VOXLllAMeNrX4IhJCsNYu86";
  };

  users.mutableUsers = false;

  networking.hostName = "robert-nixos-utm";
  system.stateVersion = "23.05";
}
