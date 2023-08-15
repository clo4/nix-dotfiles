{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programs.fish;
  alias = name: {
    wraps = name;
    body = "${name} $argv";
  };
in {
  options.my.programs.fish = {
    enable = mkEnableOption "my fish configuration";
    enableWslFunctions = mkEnableOption "fish wsl functions";
  };

  config = mkIf cfg.enable {
    programs.fish = mkMerge [
      {
        enable = true;

        plugins = [
          {
            name = "tide";
            src = inputs.fish-tide;
          }
        ];

        functions = {
          # Disables the greeting message
          fish_greeting = "";

          # This function is sourced every time the shell starts up
          fish_user_key_bindings = ''
            fish_default_key_bindings
            bind \cz 'fg 2>/dev/null; commandline -f repaint'
            bind \ez 'zi; commandline -f repaint'
          '';

          # Displays every path in $PATH on new lines.
          # This is similar to
          paths = ''
            for path in $PATH
              echo $path
            end
          '';

          # Better interactive output than `ls`, and it's on my home row (faster to type).
          e = "exa --sort=size --all --header --long --group-directories-first --git -- $argv";

          # Print the root of the git repository, if there is one
          git-root = "git rev-parse --git-dir | path dirname";

          # Renames the current working directory
          mvcd = ''
            set cwd $PWD
            set newcwd $argv[1]
            cd ..
            mv $cwd $newcwd
            cd $newcwd
            pwd
          '';

          # Sucks items out of the given directories into the destination directory.
          # This is useful for flattening nested directory structures.
          suck = ''
            if test (count $argv) -lt 2
              echo 'usage: suck sources... dest' >&2
              return 1
            end

            set dest $argv[-1]
            set dirs $argv[..-2]

            if not test -d $dest
              echo 'error: destination needs to be a directory'
            end

            for dir in $dirs
              set keep_dir 0

              for file in $dir/*
                set name (path basename $file)

                if test -e $dest/$name
                  echo "skipping $file"
                  set keep_dir 1
                else
                  mv $file $dest
                end
              end

              if test $keep_dir = 0
                rmdir $dir
              end
            end
          '';

          # Add a suffix to one or more files
          suff = ''
            if test (count $argv) -lt 2
              echo 'Requires 2 arguments.  Usage: suff <suffix> <files>...' >&2
              return 1
            end

            set suffix $argv[1]
            set paths $argv[2..]

            for path in $paths
              mv $path $path$suffix
            end
          '';

          # Quick wrapper to make running `nix develop` without any arguments
          # run Fish instead of Bash.
          nix = {
            wraps = "nix";
            description = "Wraps `nix develop` to run fish instead of bash";
            body = ''
              if status is-interactive
                and test (count $argv) = 1
                and test $argv[1] = develop
                command nix develop --command (status fish-path)
              else
                command nix $argv
              end
            '';
          };

          md = alias "frogmouth";

          announce = ''
            echo $argv
            $argv
          '';

          rebuild-switch-flake = ''
            if test (uname) = Darwin
              announce darwin-rebuild switch --flake .#
            else
              announce sudo nixos-rebuild switch --flake .#
            end
          '';
        };

        shellAbbrs = {
          cmv = "command -v";

          nd = "nix develop";

          f = "fzf";

          t = "tmux";
          ta = "tmux attach; or tmux";
          tk = "tmux kill-session";
          tl = "tmux list-sessions";

          tree = "exa --tree";

          rsf = "rebuild-switch-flake";

          "," = "git";
          ",a" = "git add";
          ",ap" = "git add --patch";
          ",ad" = "git add .";
          ",r" = "git restore";
          ",rs" = "git restore --staged";
          ",c" = "git commit";
          ",ca" = "git commit --amend";
          ",d" = "git diff";
          ",m" = "git merge";
          ",s" = "git status";
          ",p" = "git push";
          ",pu" = "git pull";
          ",f" = "git fetch";
          ",fu" = "git fetch upstream";
          ",sw" = "git switch";
          ",sc" = "git switch -c";
          ",b" = "git branch";

          "-" = "cd -";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
        };
      }
      (mkIf cfg.enableWslFunctions {
        functions.wsl = alias "wsl.exe";
      })
    ];
  };
}
