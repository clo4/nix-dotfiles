{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programConfig.ghostty;
in {
  options = {
    my.programConfig.ghostty.enable = mkEnableOption "my Ghostty config";
  };
  config = mkIf cfg.enable {
    programConfig.ghostty.enable = true;

    programConfig.ghostty.settings = {
      # window-padding-balance = true;
      cursor-style-blink = false;
      mouse-hide-while-typing = true;
      macos-option-as-alt = true;

      font-family = "JetBrainsMono Nerd Font";

      background = "282828";
      foreground = "ebdbb2";

      unfocused-split-opacity = 0.96;

      # Gruvbox Dark, theme colors taken from Kitty's version
      palette = [
        "0=#282828" # black
        "8=#928374" # light black

        "1=#cc241d" # red
        "9=#fb4934" # light red

        "2=#98971a" # green
        "10=#b8bb26" # light green

        "3=#d79921" # yellow
        "11=#fabd2d" # light yellow

        "4=#458588" # blue
        "12=#83a598" # light blue

        "5=#b16286" # magenta
        "13=#d3869b" # light magenta

        "6=#689d6a" # cyan
        "14=#8ec07c" # light cyan

        "7=#a89984" # light gray
        "15=#928374" # dark gray
      ];
    };
  };
}
