{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.ghostty;
in {
  options = {
    my.programs.ghostty.enable = mkEnableOption "my Ghostty config";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      settings = {
        # Fixes an issue on macOS where if the terminal launches before the
        # Nix partition is mounted then the shell will fail to start.
        command = let
          # shell = "$SHELL -c 'exec nu'";
          shell = "$SHELL";
        in
          if pkgs.stdenv.isDarwin
          then ''
            /bin/bash --noprofile --norc -c "/bin/wait4path ${builtins.head (splitString " " shell)} && exec -l ${shell}"
          ''
          else shell;

        unfocused-split-opacity = 0.80;
        # unfocused-split-fill = "#000000";
        cursor-style-blink = false;
        mouse-hide-while-typing = true;

        quit-after-last-window-closed = true;

        macos-option-as-alt = true;
        window-theme = "auto";

        font-family = "RobotoMonoNL Nerd Font Mono";
        font-size = 12;

        window-height = 60;
        window-width = 170;

        # The default window padding is 2, which is mostly fine, but on my monitor
        # it's a little hard to see the characters right at the edge. It's a simple
        # solution to just double the padding when it's so small already.
        window-padding-x = 4;
        window-padding-y = 4;

        theme = "GruvboxDark";

        # Disables most ligatures entirely, keeping this around in case I ever change fonts
        # font-feature = ["-liga" "-dlig" "-calt"];
      };

      keybindings = {
        # TODO: Increase speed of pane resizing?
        "super+left" = "goto_split:left";
        "super+right" = "goto_split:right";
        "super+up" = "goto_split:top";
        "super+down" = "goto_split:bottom";

        "super+control+left" = "resize_split:left,40";
        "super+control+right" = "resize_split:right,40";
        "super+control+up" = "resize_split:up,40";
        "super+control+down" = "resize_split:down,40";

        "page_up" = "scroll_page_fractional:-0.5";
        "page_down" = "scroll_page_fractional:0.5";
      };
    };
  };
}
