{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.my.programs.neovim;

  mkPluginLink =
    group: p:
    let
      subdir = if p.start or false then "start" else "opt";
    in
    {
      "${config.xdg.dataHome}/nvim/site/pack/${group}/${subdir}/${p.name}" = {
        source = p.src;
        recursive = p.recursive;
      };
    };

  links = lib.foldlAttrs (
    acc: group: plugins:
    lib.foldl' (acc2: pl: acc2 // mkPluginLink group pl) acc plugins
  ) { } cfg.packages;

  pluginType = lib.types.submodule (
    { ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Directory name used with :packadd.";
        };
        src = lib.mkOption {
          type = lib.types.path;
          description = "Plugin source derivation.";
        };
        start = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Install under start/ when true, opt/ when false.";
        };
        recursive = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Symlink the plugin files recursively when true, or the entire directory when false.";
        };
      };
    }
  );

in
{
  options.my.programs.neovim = with lib; {
    enable = mkEnableOption "Install NeoVim plugins via packpath" // {
      default = true;
    };
    packages = mkOption {
      type = types.attrsOf (types.listOf pluginType);
      default = { };
      description = "Mapping from pack group to plugin list.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file = links;
  };
}
