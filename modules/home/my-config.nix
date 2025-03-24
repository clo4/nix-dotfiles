# A very simple Home Manager module that allows me to easily create out-of-store symlinks.
{
  pkgs,
  config,
  lib,
  flake,
  ...
}:
let
  inherit (lib) types;
  cfg = config.my.config;
  mkConfigSymlink =
    relativePath: config.lib.file.mkOutOfStoreSymlink "${cfg.directory}/${relativePath}";
in
{
  options.my.config = {
    directory = lib.mkOption {
      default = flake;
      type = types.path;
      description = ''
        Path to the directory that the configuration will be linked to.
        This is an absolute path on the system, which will be the flake's
        path in the store if not specified.
      '';
      example = lib.literalExpression ''
        ''${config.home.homeDirectory}/.config/system-configuration
      '';
    };

    source = lib.mkOption {
      default = { };
      type = with types; attrsOf (nullOr (either str path));
      description = ''
        Mapping from system path to path relative to the source directory.
        The value can be either a directory or a file.
        To reference your XDG_CONFIG_HOME, use Home Manager's `xdg.configHome`
        value.
      '';
    };

    force = lib.mkOption {
      default = true;
      type = types.bool;
      description = ''
        Whether the configuration links should override whatever exists already.
      '';
    };
  };

  config = lib.mkIf (cfg.source != { }) {
    home.file =
      let
        nonNull = lib.filterAttrs (n: v: v != null) cfg.source;
      in
      builtins.mapAttrs (_: v: {
        source = mkConfigSymlink v;
        force = cfg.force;
      }) nonNull;
  };
}
