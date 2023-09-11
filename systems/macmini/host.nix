{pkgs, ...}: {
  imports = [
    ../host.nix
    ./brew.nix
  ];

  # This has to be set on macOS to make fish a usable shell
  environment.shells = [pkgs.fish];

  users.users.robert = {
    description = "Robert";
    home = "/Users/robert";
    shell = pkgs.fish;
  };

  programs.fish.fixPathOrder = true;

  # This needs to be reapplied after system updates
  security.pam.enableSudoTouchIdAuth = true;

  networking.hostName = "macmini";

  # Hides desktop icons (but they're still accessible through Finder)
  system.defaults.finder.CreateDesktop = false;

  # TODO: Should this be moved to the common config?
  services.nix-daemon.enable = true;

  system.stateVersion = 4;
}
