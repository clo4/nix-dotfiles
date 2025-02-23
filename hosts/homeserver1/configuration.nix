{
  flake,
  inputs,
  config,
  pkgs,
  perSystem,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default

    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot

    # inputs.quadlet-nix.nixosModules.quadlet

    ./disko.nix
    ./minecraft
    # ./minecraft/please.nix
    # ./minecraft/postgres.nix
  ];

  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.enable = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "homeserver1";
  networking.hostId = "027fb931";
  networking.useDHCP = true;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.self.flake = inputs.self;

  age.secrets.tailscale-homeserver1.file = "${flake}/secrets/tailscale-homeserver1.age";
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-homeserver1.path;
    openFirewall = true;
    extraUpFlags = [
      "--accept-dns=false"
    ];
  };

  users.users.robert = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "podman"
      "systemd-journal"
      "minecraft-family"
    ];
    hashedPassword = "$6$bj5noqbzbRUVifze$v2e9wChwgDsa8CVG8KpLJngUYOsVHofv0jWbzuUKzInCGxRveU5RGeO5KQ5W4pmBDqtaBHSfLudbwKgqjw/Em1";
    # packages = [
    #   perSystem.self.rcon-cli
    #   perSystem.self.mrpack-install
    # ];
    openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/macbook-air/users/robert/authorized_keys"
      "${flake}/hosts/macmini/users/robert/authorized_keys"
    ];
  };
}
