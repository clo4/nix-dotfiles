{...}: {
  environment.systemPath = ["/opt/homebrew/bin"];
  homebrew.enable = true;

  homebrew.casks = [
    "rectangle"
    "obsidian"
    "zed"
    "1password"
    "raycast"
  ];
}
