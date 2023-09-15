{...}: {
  environment.systemPath = ["/opt/homebrew/bin"];
  homebrew.enable = true;

  # Applications are installed through Homebrew because there's a wider selection available
  # on macOS and the applications tend to be more up-to-date.
  homebrew.casks = [
    # homerow isn't available as a cask yet
    "1password"
    "affinity-designer"
    "affinity-photo"
    "affinity-publisher"
    "appcleaner"
    "arc"
    "audio-hijack"
    "bartender"
    "elgato-camera-hub"
    "grandperspective"
    "hammerspoon"
    "iina"
    "karabiner-elements"
    "linearmouse"
    "little-snitch"
    "loopback"
    "monitorcontrol"
    "obs"
    "obsidian"
    "plover"
    "raycast"
    "rectangle"
    "rio"
    "spotify"
    "transmission"
    "wezterm"
    "zed"
    "zed"
  ];
}
