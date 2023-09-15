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

  # TODO: Should this be moved to the common config?
  services.nix-daemon.enable = true;

  system.stateVersion = 4;

  system.defaults.NSGlobalDomain = {
    AppleInterfaceStyleSwitchesAutomatically = true;
    ApplePressAndHoldEnabled = false;
    AppleShowAllExtensions = true;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    "com.apple.keyboard.fnState" = true;
  };

  system.defaults.dock.autohide = true;

  system.defaults.LaunchServices.LSQuarantine = false;

  system.defaults.finder = {
    ShowPathbar = true;
    # Hides desktop icons (but they're still accessible through Finder)
    CreateDesktop = false;
    # This magic string makes it search the current folder by default
    FXDefaultSearchScope = "SCcf";
    # Use the column view by default-- the obviously correct and best view
    FXPreferredViewStyle = "clmv";
  };
}
