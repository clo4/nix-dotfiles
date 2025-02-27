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

    ./disko.nix
    ./minecraft
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

  # The srvos server profile disables documentation by default, but it's
  # useful to have it enabled so I can reference things quickly in an
  # SSH session instead of trying to find the documentation online.
  srvos.server.docs.enable = true;

  # Srvos also sets the timezone to UTC automatically. I want this to be
  # my current location because it will also handle DST changes smoothly.
  # A timer set for "04:00" should go off when my wall clock says it's 4.
  time.timeZone = "Australia/Sydney";

  age.secrets.tailscale-homeserver1.file = "${flake}/secrets/tailscale-homeserver1.age";
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-homeserver1.path;
    openFirewall = true;
    extraUpFlags = [
      # I don't remember why I have this here, but it's carried over from my
      # VPS setup, and I'm too afraid to change it in case it breaks something.
      "--accept-dns=false"
    ];
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  users.users.robert = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "podman"
      "systemd-journal"
    ];
    hashedPassword = "!";
    openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/macbook-air/users/robert/authorized_keys"
      "${flake}/hosts/macmini/users/robert/authorized_keys"
    ];
  };
}
