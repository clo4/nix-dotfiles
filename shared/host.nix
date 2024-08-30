{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ../modules/host
  ];

  time.timeZone = "Australia/Sydney";

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  environment.systemPackages = with pkgs; [
    mosh
  ];

  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "home-manager=${inputs.home-manager}"
  ];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    # This seems to cause issues:
    # https://github.com/NixOS/nix/issues/7273
    #auto-optimise-store = true;
    trusted-substituters = [
      "https://helix.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
    trusted-users = [
      "root"
      "@admin"
    ];
  };

  nix.registry = {
    # Makes `nix run nixpkgs#...` run using the latest unstable
    nixpkgs.flake = inputs.nixpkgs-unstable;

    # inputs.self is a reference to this flake, which allows self-references.
    # In this case, adding this flake to the registry under the name `my`,
    # which is the name I use any time I'm customising stuff.
    # (at time of writing, this is only used for `nix flake init -t my#...`)
    my.flake = inputs.self;

    mkshell.flake = inputs.mkshell;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # This needs to be set to get the default system-level fish configuration, such
  # as completions for Nix and related tools. This is also required because on macOS
  # the $PATH doesn't include all the entries it should by default.
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  services.tailscale.enable = true;
}
