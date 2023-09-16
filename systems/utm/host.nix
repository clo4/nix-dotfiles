# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../shared/host.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "robert-nixos-utm"; # Define your hostname.

  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.polkit.enable = true; # required for sway
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.robert = {
    description = "Robert";
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    hashedPassword = "$y$j9T$/DELHBb5Gc.uI/Cyr6KGo1$AgxXRZnEcH74IJnaN.L4VOXLllAMeNrX4IhJCsNYu86";
    shell = pkgs.fish;
  };

  users.mutableUsers = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";
}
