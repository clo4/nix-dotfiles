# A very simple Home Manager module that allows me to easily create out-of-store symlinks.
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  cfg = config.my.config;
  home = config.home.homeDirectory;
  mkConfigSymlink =
    relativePath: config.lib.file.mkOutOfStoreSymlink "${home}/${cfg.directory}/${relativePath}";
in
{
  options.my.config = {
    directory = lib.mkOption {
      default = lib.null;
      type = types.nullOr types.str;
      description = ''
        Path to the directory that the configuration will be linked to.
        This directory is relative to your $HOME. For example, if your
        configuration lives in ~/.dotfiles, you would use ".dotfiles"
        as the value.
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
      default = false;
      type = types.bool;
      description = ''
        Whether the configuration links should override whatever exists already.
      '';
    };
  };

  # TODO: This could become an assert - if source != { }, assert sourceDirectory != null
  config = lib.mkIf (cfg.directory != null && cfg.source != { }) {
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
