{...}: {
  environment.systemPath = ["/opt/homebrew/bin"];
  homebrew.enable = true;

  # Applications are installed through Homebrew because there's a wider selection available
  # on macOS and the applications tend to be more up-to-date.
  homebrew.casks = [
    # NOTE: Homerow isn't available as a cask yet

    "1password"

    # Media tools
    "audio-hijack"
    "loopback"
    "blender"
    "affinity-designer"
    "affinity-photo"
    "affinity-publisher"

    # Loosely, productivity
    "raycast"
    "appcleaner"

    # Loosely, social platforms
    "signal"
    "discord"

    "crossover"
    "steam"
    "keymapp"

    "docker"
    "elgato-camera-hub"
    "firefox"
    "grandperspective"
    "iina"
    "linearmouse"
    "little-snitch"
    "monitorcontrol"
    "obs"
    "obsidian"
    "rectangle"
    "spotify"
    "transmission"
    "wezterm"
    "zed"
  ];
}
