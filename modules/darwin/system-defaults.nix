{
  system.defaults.NSGlobalDomain = {
    ApplePressAndHoldEnabled = false;
    AppleShowAllExtensions = true;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
    NSWindowShouldDragOnGesture = true;
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    # Explicitly enabling media keys because the media keycodes themselves are
    # used for some shortcuts
    "com.apple.keyboard.fnState" = false;
  };

  system.defaults.dock.autohide = true;

  system.defaults.finder = {
    ShowPathbar = true;
    # This magic string makes it search the current folder by default
    FXDefaultSearchScope = "SCcf";
    # Use the column view by default (the obviously correct and best view)
    FXPreferredViewStyle = "clmv";
  };
}
