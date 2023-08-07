{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programs.fish;
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

        # If this keeps growing, it might be better to move each function to its own file
        # in a fish/functions directory and use home-manager's symlinking feature.
        # I have documentation for this in my Obsidian notes.

        # In all cases, functions are a better choice than shell aliases.
        # Fish automatically generates functions from the `alias` command anyway,
        # so a function just gives you more control over it with no downside.
        # In Bash/Zsh, shell aliases are *proper* cursed, and you should NEVER touch them.
        # Seriously, the worst bugs I've ever had to deal with were because of aliases.
        # Just use functions, they're real easy to define and way less buggy!

        functions = {
          # Disables the greeting message
          fish_greeting = "";

          fish_user_key_bindings = ''
            bind \cz 'fg 2>/dev/null; commandline -f repaint'
          '';

          # Displays every path in $PATH on new lines
          paths = "echo \"$PATH\" | tr ':' '\\n'";

          # Better interactive output than `ls`
          e = "${pkgs.exa}/bin/exa --sort=size --all --header --long --group-directories-first -- $argv";

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

          # Moves items out of the given directories into the destination directory.
          # This is useful for flattening nested directory structures.
          flatten = ''
            if test (count $argv) -lt 2
              echo 'Requires 2 arguments.  Usage: flatten sources... dest' >&2
              return 1
            end

            set dest $argv[-1]
            set dirs $argv[..-2]

            for dir in $dirs
              mv -i $dir/* $dest
              rmdir $dir
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

          # Quick wrapper to make `nix develop` run Fish instead of Bash.
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

          md = {
            wraps = "frogmouth";
            body = "${pkgs.frogmouth}/bin/frogmouth $argv";
          };
        };

        shellAbbrs = {
          # Did you know `which` isn't a builtin?
          cmv = "command -v";

          nd = "nix develop";

          f = "fzf";

          t = "tmux";
          ta = "tmux attach; or tmux";
          tk = "tmux kill-session";
          tl = "tmux list-sessions";

          "," = "git";
          ",a" = "git add";
          ",ap" = "git add --patch";
          ",ad" = "git add .";
          ",r" = "git restore";
          ",c" = "git commit";
          ",ca" = "git commit --amend";
          ",cp" = "git commit; and git push";
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
        functions.wsl = {
          wraps = "wsl.exe";
          body = "wsl.exe $argv";
        };
      })
    ];
  };
}
