{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.my.programs.tmux;
in {
  options.my.programs.tmux = {
    enable = mkEnableOption "my tmux configuration";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      escapeTime = 50;
      historyLimit = 10000;
      mouse = true;
      terminal = "tmux-256color";
      baseIndex = 1;
      extraConfig = ''
        set-option -sa terminal-overrides ",tmux-256color:RGB"
      '';
    };
  };
}
