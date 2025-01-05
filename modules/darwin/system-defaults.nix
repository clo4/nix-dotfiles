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
    # Enables using the function keys as the F<number> key instead of OS controls
    "com.apple.keyboard.fnState" = true;
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
