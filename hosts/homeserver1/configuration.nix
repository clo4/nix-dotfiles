{
  flake,
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.default
    inputs.agenix.nixosModules.default

    inputs.srvos.nixosModules.server
    inputs.srvos.nixosModules.mixins-systemd-boot

    ./disko.nix
    # ./minecraft
    # ./vrising.nix
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
  boot.kernelPackages = pkgs.linuxPackages_latest;
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

  age.secrets.tailscale-homeserver1.file = ./tailscale-homeserver1.age;
  services.tailscale = {
    enable = true;
    authKeyFile = config.age.secrets.tailscale-homeserver1.path;
    openFirewall = true;
    extraUpFlags = [
      "--advertise-exit-node"
      "--exit-node-allow-lan-access"
    ];
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  environment.etc."configuration-revision".text = flake.rev or flake.dirtyRev;

  users.users.robert = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "podman"
      "systemd-journal"
    ];
    hashedPassword = "!";

    # TODO: Think of a better place to store these keys. Maybe in users/robert/<device>?
    openssh.authorizedKeys.keys = [
      # My iPhone, blink terminal
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkVAe4iwrprDibMgY1m0BeUPgrKBRErKRfLfxjVl+lu"
      # My iPad, blink terminal
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGcz3Qiqix5lJPsDeE+RY2q64Bpl+jY0tLO/fUM5TNr"
    ];

    # Allows each system's root and user to connect to the server, which
    # is necessary to use it as a builder.
    openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/macbook-air/id_ed25519.pub"
      "${flake}/hosts/macbook-air/users/robert/id_ed25519.pub"

      "${flake}/hosts/macmini/id_ed25519.pub"
      "${flake}/hosts/macmini/users/robert/id_ed25519.pub"
    ];
  };
}
