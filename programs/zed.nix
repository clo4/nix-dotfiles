{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programConfig.zed;
  formatWithPrettier = {
    format_on_save = "on";
    formatter.external = {
      command = pkgs.nodePackages_latest.prettier;
      arguments = ["--stdin-filepath" "{buffer_path}"];
    };
  };
in {
  imports = [
    ../modules/home/zed.nix
  ];
  options = {
    my.programConfig.zed.enable = mkEnableOption "my Zed config";
  };
  config = mkIf cfg.enable {
    programConfig.zed.enable = true;
    programConfig.zed.settings = {
      features.copilot = false;
      theme = "Gruvbox Dark";
      buffer_font_size = 12;
      vim_mode = true;
      cursor_blink = false;
      show_copilot_suggestions = false;
      remove_trailing_whitespace_on_save = true;
      inlay_hints.enabled = true;
      languages = {
        Rust.format_on_save = "on";
        JSON = formatWithPrettier;
        JavaScript = formatWithPrettier;
      };
      confirm_quit = false;
      terminal.option_as_meta = true;
      hover_popover_enabled = true;
      soft_wrap = "none";
      buffer_font_family = "RobotoMono Nerd Font";
    };
  };
}
