{
  # The HTML manual build (`darwin-manual-html` / `darwin-help`) is broken with
  # current nixpkgs-unstable: nix-darwin's doc builder still passes
  # `--toc-depth` to `nixos-render-docs manual html`, but nixpkgs removed that
  # flag in favour of `--sidebar-depth`. nix-darwin master hasn't caught up yet.
  # Disable the HTML docs/help until it does; man pages are unaffected.
  documentation.doc.enable = false;

  # `darwin-uninstaller` evaluates its OWN stock darwin-system (see
  # pkgs/darwin-uninstaller/default.nix) which re-enables the HTML manual above,
  # so it must be dropped from the system path too, otherwise it drags the
  # broken `darwin-manual-html` back into the closure. It remains runnable with
  # `sudo nix run nix-darwin#darwin-uninstaller`. Revert both once nix-darwin
  # switches to `--sidebar-depth`.
  system.tools.darwin-uninstaller.enable = false;

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
