{pkgs, ...}: let
  language = _: t: t;
in {
  imports = [
    ../../shared/host.nix
    ../../shared/brew.nix
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

  system.defaults.CustomUserPreferences = {
    NSGlobalDomain = {
      NSWindowShouldDragOnGesture = true;

      # NOTE: Disabling for now because RSI is making a pretty good case for
      # non-linear inputs...
      #
      # This should really be in the settings app
      # "com.apple.mouse.scaling" = "-1";
    };
    "com.superultra.homerow" = {
      label-characters = "arstneiowfpluy";
      scroll-keys = "mnei";
      map-arrow-keys-to-scroll = false;
      launch-at-login = true;
      is-experimental-support-enabled = true;
      # The shortcut really is stored as the shift symbol and command symbol!
      non-search-shortcut = "⇧⌘Space";
    };
  };

  system.defaults.NSGlobalDomain = {
    # Automatic dark mode at night
    # AppleInterfaceStyleSwitchesAutomatically = true;

    # Disabling this means you can hold to repeat keys
    ApplePressAndHoldEnabled = false;

    # I *always* want to know the file type
    AppleShowAllExtensions = true;

    # I type fine anyway, stop getting in my way
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    # 15 milliseconds until the key repeats, then 2 milliseconds
    # between subsequent inputs. This can be achieved in the settings UI
    InitialKeyRepeat = 15;
    KeyRepeat = 2;

    # Enables using the function keys as the F<number> key instead of OS controls
    "com.apple.keyboard.fnState" = true;
  };

  # I don't change the speed because I think it's fine by default honestly.
  # Most of the time I don't use the dock anyway, instead just navigating with
  # Raycast and Homerow.
  system.defaults.dock.autohide = true;

  # Pretty sure this doesn't do anything anymore :(
  system.defaults.LaunchServices.LSQuarantine = false;

  system.defaults.finder = {
    # Shows a breadcrumb trail down the bottom of the Finder window
    ShowPathbar = true;

    # Hides desktop icons (but they're still accessible through Finder).
    # Because it never creates a desktop, you can't *click* on the desktop.
    CreateDesktop = false;

    # This magic string makes it search the current folder by default
    FXDefaultSearchScope = "SCcf";

    # Use the column view by default-- the obviously correct and best view
    FXPreferredViewStyle = "clmv";
  };
}
