# Declarative fish plugin installation
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.my.programs.fish;

  fishIndent =
    name: text:
    pkgs.runCommand name {
      nativeBuildInputs = [ pkgs.fish ];
      inherit text;
      passAsFile = [ "text" ];
    } "env HOME=$(mktemp -d) fish_indent < $textPath > $out";

  babelfishTranslate =
    path: name:
    pkgs.runCommand "${name}.fish" { } ''
      ${pkgs.babelfish}/bin/babelfish < ${path} > $out
    '';
in
{
  options = {
    my.programs.fish.plugins = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      description = ''
        Plugins that will be installed and activated.
      '';
    };
  };

  config = {
    # FIXME: This is no longer necessary now that ZSH handles sourcing it.
    # xdg.dataFile."fish/vendor_conf.d/00_hm-session-vars.fish".source =
    #   let
    #     sessionVars = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    #   in
    #   babelfishTranslate sessionVars "hm-session-vars";

    xdg.dataFile."fish/vendor_conf.d/00_source_plugins.fish".source = lib.mkIf (cfg.plugins != [ ]) (
      fishIndent "source_plugins.fish" ''
        for plugin in ${lib.concatStringsSep " " cfg.plugins}
          if test -d $plugin/functions
            set fish_function_path $fish_function_path[1] $plugin/functions $fish_function_path[2..]
          end

          if test -d $plugin/completions
            set fish_complete_path $fish_complete_path[1] $plugin/completions $fish_complete_path[2..]
          end

          # Sourcing files in both places allows me to support OMF plugins too, just in case.
          for file in $plugin/conf.d/*.fish $plugin/*.fish
            test -f $file -a -r $file
            and source $file
          end
        end
      ''
    );

    # The following has been adapted from the Fish module of home-manager:
    # https://github.com/nix-community/home-manager/blob/0d7908bd09165db6699908b7e3970f137327cbf0/modules/programs/fish.nix#L4
    # This is temporary and will be cleaned up in the future.

    programs.man.generateCaches = true;

    xdg.dataFile."fish/generated_completions".source =
      let
        # paths later in the list will overwrite those already linked
        destructiveSymlinkJoin =
          args_@{
            name,
            paths,
            preferLocalBuild ? true,
            allowSubstitutes ? false,
            postBuild ? "",
            ...
          }:
          let
            args =
              removeAttrs args_ [
                "name"
                "postBuild"
              ]
              // {
                # pass the defaults
                inherit preferLocalBuild allowSubstitutes;
              };
          in
          pkgs.runCommand name args ''
            mkdir -p $out
            for i in $paths; do
              if [ -z "$(find $i -prune -empty)" ]; then
                cp -srf $i/* $out
              fi
            done
            ${postBuild}
          '';

        generateCompletions =
          let
            getName =
              attrs: attrs.name or "${attrs.pname or "«pname-missing»"}-${attrs.version or "«version-missing»"}";
          in
          package:
          pkgs.runCommand "${getName package}-fish-completions"
            {
              srcs =
                [ package ]
                ++ lib.filter (p: p != null) (
                  builtins.map (outName: package.${outName} or null) config.home.extraOutputsToInstall
                );
              nativeBuildInputs = [ pkgs.python3 ];
              buildInputs = [ pkgs.fish ];
              preferLocalBuild = true;
            }
            ''
              mkdir -p $out
              for src in $srcs; do
                if [ -d $src/share/man ]; then
                  find -L $src/share/man -type f \
                    | xargs python ${pkgs.fish}/share/fish/tools/create_manpage_completions.py --directory $out \
                    > /dev/null
                fi
              done
            '';
      in
      destructiveSymlinkJoin {
        name = "${config.home.username}-fish-completions";
        paths =
          let
            cmp = (a: b: (a.meta.priority or 0) > (b.meta.priority or 0));
          in
          map generateCompletions (lib.sort cmp config.home.packages);
      };

    xdg.dataFile."fish/vendor_conf.d/99_generated_completions.fish".source =
      fishIndent "99_generated_completions.fish" ''
        set -l genpath ${config.xdg.dataHome}/fish/generated_completions

        if test -d $genpath; and not contains -- genpath $PATH
          set --append fish_complete_path $genpath
        end
      '';
  };
}
