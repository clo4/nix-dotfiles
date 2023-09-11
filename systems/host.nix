{
  pkgs,
  inputs,
  ...
}: {
  time.timeZone = "Australia/Sydney";

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  environment.systemPackages = with pkgs; [
    mosh
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    "home-manager=${inputs.home-manager}"
  ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # I always want the latest version of Helix. They do their best to
  # keep it building, and I've only ever had trouble with it twice.
  # Even then, that's exactly the problem that Nix solves, so I'm not
  # concerned at all about stability.
  nixpkgs.overlays = [
    inputs.helix.overlays.default
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  # This needs to be set to get the default system-level fish configuration, such
  # as completions for Nix and related tools. This is also required because on macOS
  # the $PATH doesn't include all the entries it should by default.
  programs.fish.enable = true;

  # services.tailscale.enable = true;
}
