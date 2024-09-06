{ pkgs, ... }:
{
  imports = [
    ../../shared/host.nix
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "robert";
    startMenuLaunchers = true;
    nativeSystemd = true;
  };

  users.users.robert = {
    description = "Robert";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
    hashedPassword = "$y$j9T$/DELHBb5Gc.uI/Cyr6KGo1$AgxXRZnEcH74IJnaN.L4VOXLllAMeNrX4IhJCsNYu86";
  };

  # Using a purely declarative user setup. This means any future users will have to
  # have a password hash generated with `mkpasswd`
  users.mutableUsers = false;

  # Needs to be set explicitly because nixos-wsl disables this for ease of installation
  security.sudo.wheelNeedsPassword = true;
  users.users.root.hashedPassword = "$y$j9T$59FLHlmQYvySQOZazkMrV1$i.FXwBacc.xIed9TTl5ba1JyiFQ8vAF/UOavLfg/ZP/";

  networking.hostName = "robert-nixos-wsl";

  system.stateVersion = "23.11";
}
