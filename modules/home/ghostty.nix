{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programConfig.ghostty;

  eitherStrBoolNum = with types; either str (either bool number);

  # Either a (str | bool | number) or a list of (str | bool | number)
  anyConfigType = with types;
    either (listOf eitherStrBoolNum) eitherStrBoolNum;

  boolToStr = bool:
    if bool == true
    then "true"
    else "false";

  toGhosttyConfig = generators.toKeyValue {
    listsAsDuplicateKeys = true;
    mkKeyValue = key: value: let
      value' =
        (
          if isBool value
          then boolToStr
          else toString
        )
        value;
    in "${key} = ${value'}";
  };

  enableShellIntegration = (cfg.settings.shell-integration or null) != "none";

  shellIntegrationInit = {
    bash = ''
      if test -n "$GHOSTTY_RESOURCES_DIR"; then
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
      fi
    '';
    fish = ''
      if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
        set --prepend fish_complete_path "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_completions.d"
      end
    '';
    zsh = ''
      if test -n "$GHOSTTY_RESOURCES_DIR"; then
        autoload -Uz -- "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
        ghostty-integration
        unfunction ghostty-integration
      fi
    '';
  };
in {
  options.programConfig.ghostty = {
    enable = mkEnableOption "Ghostty terminal emulator";

    settings = mkOption {
      type = types.attrsOf anyConfigType;
      default = {};
      example = literalExpression ''
        {}
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/ghostty/config`.
      '';
    };

    # Want to support:
    # - Automatic font installation and configuration
    # - Automatic theme installation from mbadolato/iTerm2-Color-Schemes
    # - Configuring the shell integration per shell
    # - Easier way to configure the keymaps

    extraConfig = mkOption {
      default = "";
      type = types.lines;
      description = "Additional configuration to add.";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."ghostty/config" = {
      text = concatStringsSep "\n" [
        ''
          # Generated by Home Manager.
          # See https://github.com/mitchellh/ghostty
        ''
        (optionalString enableShellIntegration ''
          # Shell integration is sourced and configured manually
          shell-integration = none
        '')
        (toGhosttyConfig cfg.settings)
        cfg.extraConfig
      ];
    };

    programs.bash.initExtra =
      mkIf enableShellIntegration shellIntegrationInit.bash;

    programs.fish.interactiveShellInit =
      mkIf enableShellIntegration shellIntegrationInit.fish;

    programs.zsh.initExtra =
      mkIf enableShellIntegration shellIntegrationInit.zsh;
  };
}
