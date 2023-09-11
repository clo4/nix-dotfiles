{...}: {
  environment.systemPath = ["/opt/homebrew/bin"];
  homebrew.enable = true;

  homebrew.casks = [
    "1password"
    "elgato-camera-hub"
    "grandperspective"
    "hammerspoon"
    "iina"
    "obs"
    "obsidian"
    "raycast"
    "rectangle"
    "rio"
    "zed"
  ];
}
