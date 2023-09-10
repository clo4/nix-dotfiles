{
  lib,
  pkgs,
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
    enableGreetingTouchIdCheck = mkEnableOption "checking for pam_tid.so on startup";
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
          # Not sure if I should make this another item in the list,
          # for now it's probably fine here but if I have to add another
          # check this will have to get more complicated.
          fish_greeting =
            if cfg.enableGreetingTouchIdCheck
            then ''
              if not grep -qE '^auth\\s+sufficient\\s+pam_tid\\.so' /etc/pam.d/sudo
                set fg_red (set_color red)
                set fg_red_bg_yellow (set_color red --background yellow)
                set fg_yellow_bg_red (set_color yellow --background red)
                set normal (set_color normal)
                echo "
                  $fg_red▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
                  $fg_red_bg_yellow▎                                        $fg_yellow_bg_red▊$normal
                  $fg_red_bg_yellow▎ $(set_color --bold black)Touch ID will not work with sudo until $fg_yellow_bg_red▊$normal
                  $fg_red_bg_yellow▎ $(set_color --bold black)the system configuration is reapplied. $fg_yellow_bg_red▊$normal
                  $fg_red_bg_yellow▎                                        $fg_yellow_bg_red▊$normal
                  $fg_red▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔$normal
                "
              end
            ''
            else "";

          # This function is sourced every time the shell starts up
          fish_user_key_bindings = ''
            fish_default_key_bindings
            bind \cz 'fg 2>/dev/null; commandline -f repaint'
            bind \ez 'zi; commandline -f repaint'

            # Not sure why but the order of these is broken by default.
            # expand-abbr needs to happen first so the cursor is
            # still over the abbreviation when it tries to expand.
            bind ' ' expand-abbr self-insert
            bind ';' expand-abbr self-insert
            bind '|' expand-abbr self-insert
            bind '&' expand-abbr self-insert
            bind '>' expand-abbr self-insert
            bind '<' expand-abbr self-insert
            bind ')' expand-abbr self-insert
          '';
          # Displays every path in $PATH on new lines.
          # This is similar to
          paths = ''
            for path in $PATH
              echo -- $path
            end
          '';

          # Better interactive output than `ls`, and it's on my home row (faster to type).
          e = "eza --sort=size --all --header --long --group-directories-first --git -- $argv";

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

          # frogmouth is a fantastic markdown reader but it's a bit of a
          # (frog)mouthful to type
          md = alias "frogmouth";

          announce = ''
            echo -- "$argv"
            $argv
          '';

          # switch system flake correctly regardless of the operating system
          rebuild-switch-flake = ''
            if test (uname) = Darwin
              announce darwin-rebuild switch --flake .#
            else
              announce sudo nixos-rebuild switch --flake .#
            end
          '';

          # Why's it called 'o'? Because it's really good ;)
          # I'm joking, it's just because it's on my home row (Colemak layout)
          o = {
            wraps = "cd";
            description = "Interactive cd that offers to create directories";
            body = ''
              # Some git trickery first. If the function is called with no arguments,
              # typically that means to cd to $HOME, but we can be smarter - if you're
              # in a git repo and not in its root, cd to the root.
              if test (count $argv) -eq 0
                set git_root (git rev-parse --git-dir 2>/dev/null | path dirname)
                if test $status -eq 0 -a "$git_root" != .
                  cd $git_root
                  return 0
                end
              end

              # Now that's out of the way
              cd $argv
              set cd_status $status
              if test $cd_status -ne 0
                and ${pkgs.gum}/bin/gum confirm "Create the directory? ($argv[-1])"
                echo "Creating directory"
                command mkdir -p -- $argv[-1]
                builtin cd $argv[-1]
                return 0
              else
                return $cd_status
              end
            '';
          };

          # cd to a temporary directory
          tcd = ''
            cd (mktemp -d | tee)
          '';

          # Erase an item from an array by value rather than by index.
          # The normal syntax is `set -e name[index]`, eg. `set -e PATH[2]`
          # but this is bad for interactive use because you need to know
          # the index of the item beforehand. Using the `erase_item` function,
          # you can easily erase an item from an array if you know its value.
          # For each value that isn't found in the array, the return value is
          # incremented by 1.
          #
          #     $ set arr a b c d e
          #     $ erase_item arr c e
          #     $ echo $arr
          #     a b d
          #
          # The function is named with underscores to make it look and feel more like
          # a built-in fish function instead of something I wrote.
          erase_item = ''
            set varname $argv[1]
            set retval 0
            # Big O isn't optimal, but executes faster because `contains` is a builtin
            for item in $argv[2..]
              set -l index (contains --index -- $item $$varname)
              if set -q index[1]
                set -e {$varname}[$index]
              else
                set retval (math $retval + 1)
              end
            end
            return $retval
          '';
        };

        shellAbbrs = {
          cmv = "command -v";

          nd = "nix develop";
          nfuc = "nix flake update --commit-lock-file";

          f = "fzf";

          t = "tmux";
          ta = "tmux attach; or tmux";
          tk = "tmux kill-session";
          tl = "tmux list-sessions";

          tree = "eza --tree";

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
          ",pf" = "git push --force";
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
