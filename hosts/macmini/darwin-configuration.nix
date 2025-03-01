{
  inputs,
  pkgs,
  lib,
  perSystem,
  flake,
  ...
}:
{
  imports = [
    inputs.self.darwinModules.system-defaults
    inputs.self.darwinModules.fish-environment

    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  users.users.robert = {
    description = "Robert";
    home = "/Users/robert";
    openssh.authorizedKeys.keys = [
      # My iPhone, blink terminal
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkVAe4iwrprDibMgY1m0BeUPgrKBRErKRfLfxjVl+lu"
    ];
    openssh.authorizedKeys.keyFiles = [
      "${flake}/hosts/macbook-air/users/robert/authorized_keys"
      "${flake}/hosts/macmini/users/robert/authorized_keys"
    ];
  };

  # This needs to be reapplied after each system update. My Fish configuration
  # will warn about this if it detects the line it adds to sudo_local is absent.
  security.pam.services.sudo_local.touchIdAuth = true;

  networking.hostName = "macmini";

  system.stateVersion = 6;

  home-manager.backupFileExtension = "hm-backup";

  nix-homebrew.enable = true;
  # A user needs to own the prefix, so we'll make it my account
  nix-homebrew.user = "robert";

  environment.systemPackages = [
    pkgs.fish
    pkgs.mosh
  ];

  # Not sure about adding in vendor_conf.d because tools can just dump their init into it,
  # and because it will be included in a directory in $NIX_PROFILES, therefore
  # also $XDG_DATA_DIRS, it will be sourced during startup. This is probably fine, but
  # I want total control over what runs in my fish config.
  environment.pathsToLink = [
    # "/share/fish/vendor_conf.d"
    "/share/fish/vendor_completions.d"
    "/share/fish/vendor_functions.d"
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix.enable = true;
  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "home-manager=${inputs.home-manager}"
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [ "@admin" ];
  nix.channel.enable = false;
  # TODO: should I make 'robert' a trusted user?
  nixpkgs.config.allowUnfree = true;

  services.tailscale.enable = true;
  services.openssh.enable = true;

  environment.etc."ssh/sshd_config.d/999-disable-password-auth.conf".text = ''
    PermitRootLogin no
    PasswordAuthentication no
    KbdInteractiveAuthentication no
    UsePAM no
  '';
}
