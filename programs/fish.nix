{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programs.fish;
  # This is a no-op function that is only used by Helix to highlight an indented
  # string in the correct language. The highlight query is defined in the
  # helix.nix module.
  language = name: text: text;
  alias = name: {
    wraps = name;
    body = "${name} $argv";
  };
in {
  options.my.programs.fish = {
    enable = mkEnableOption "my fish configuration";

    enableCommandNotFound =
      mkEnableOption "my command not found handler using comma"
      // {default = true;};

    enableWslFunctions = mkEnableOption "my fish wsl alias functions";

    enableGreetingTouchIdCheck = mkEnableOption "a check for pam_tid.so on startup";
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enableCommandNotFound {
      programs.nix-index.enable = true;
      programs.nix-index.enableFishIntegration = false;

      programs.fish.functions.fish_command_not_found = language "fish" ''
        # If you run the command with comma, running the same command
        # will not prompt for confirmation for the rest of the session
        if contains $argv[1] $__fish_run_with_comma_commands
          or ${pkgs.gum}/bin/gum confirm --selected.background=2 "Run using comma?"

          # Not bothering with capturing the status of the command, just run it again
          if not contains $argv[1] $__fish_run_with_comma_commands
            set -ga __fish_run_with_comma_commands $argv[1]
          end

          ${pkgs.comma}/bin/comma -- $argv
        else
          __fish_default_command_not_found_handler $argv
        end
      '';

      programs.fish.interactiveShellInit = language "fish" ''
        # It's not necessarily an error to type the wrong command because you can still try
        # to execute it afterwards, so make the color of an unknown command less aggressive
        set -g fish_error_color yellow
      '';
    })

    (mkIf cfg.enableWslFunctions {
      programs.fish.functions.wsl = alias "wsl.exe";
    })

    (mkIf cfg.enableGreetingTouchIdCheck {
      programs.fish.functions.fish_greeting = language "fish" ''
        if not grep -qE '^auth\\s+sufficient\\s+pam_tid\\.so' /etc/pam.d/sudo
          set fg_red (set_color red)
          set fg_red_bg_yellow (set_color red --background yellow)
          set fg_yellow_bg_red (set_color yellow --background red)
          set normal (set_color normal)

          # This is the world's Most Manually Constructed McGugan Box(tm).
          # The colors are assigned to variables except for the text colors
          # because I ran into an issue where fish refused to play nice with
          # parsing it. Don't remember why, not super relevant.
          echo "
            $fg_red▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
            $fg_red_bg_yellow▎                                        $fg_yellow_bg_red▊$normal
            $fg_red_bg_yellow▎ $(set_color --bold black)Touch ID will not work with sudo until $fg_yellow_bg_red▊$normal
            $fg_red_bg_yellow▎ $(set_color --bold black)the system configuration is reapplied. $fg_yellow_bg_red▊$normal
            $fg_red_bg_yellow▎                                        $fg_yellow_bg_red▊$normal
            $fg_red▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔$normal
          "
        end
      '';
    })

    {
      programs.fish = {
        enable = true;

        plugins = [
          {
            name = "tide";
            src = inputs.fish-tide;
          }
        ];

        interactiveShellInit = language "fish" ''
          # This isn't set by default
          set -g fish_color_option blue
        '';

        functions = {
          fish_greeting = mkDefault "";

          # This function is sourced every time the shell starts up
          fish_user_key_bindings = language "fish" ''
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
          paths = language "fish" ''
            for path in $PATH
              echo -- $path
            end
          '';

          # Better interactive output than `ls`, and it's on my home row (faster to type).
          e = language "fish" ''
            eza --sort=size --all --header --long --group-directories-first --git -- $argv
          '';

          # Print the root of the git repository, if there is one
          git-root = language "fish" ''
            git rev-parse --git-dir | path dirname
          '';

          git-add-no-track = language "fish" ''
            set retval 0
            for arg in $argv
              # not incrementing retval because changing your mind isn't an error
              if not ${pkgs.gum}/bin/gum confirm "Confirm: $arg"
                continue
              end

              # subject to TOCTTOU but doesn't matter
              if not test -e $arg
                echo "file doesn't exist: $arg"
                set retval (math $retval + 1)
                continue
              end

              git add --intent-to-add -- $arg
              git update-index --assume-unchanged -- $arg
            end
            return $retval
          '';

          add-simple-shell = language "fish" ''
            if test -e flake.nix
              echo "flake already exists in this directory, bailing"
              return 1
            end
            nix flake init -t my#simple-shell
            touch flake.lock # This isn't created by default but needs to be ignored
            git-add-no-track flake.nix flake.lock
          '';

          # Renames the current working directory
          mvcd = language "fish" ''
            set cwd $PWD
            set newcwd $argv[1]
            cd ..
            mv $cwd $newcwd
            cd $newcwd
            pwd
          '';

          # Sucks items out of the given directories into the destination directory.
          # This is useful for flattening nested directory structures.
          suck = language "fish" ''
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
          suff = language "fish" ''
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
            body = language "fish" ''
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

          announce = language "fish" ''
            echo -- "$argv"
            $argv
          '';

          # switch system flake correctly regardless of the operating system
          rebuild-switch-flake = language "fish" ''
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
            body = language "fish" ''
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
          tcd = language "fish" ''
            cd (mktemp -d)
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
          erase_item = language "fish" ''
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

          n = "nix";
          nxi = "nix";
          nd = "nix develop";
          nfuc = "nix flake update --commit-lock-file";

          f = "fzf";

          t = "tmux";
          ta = "tmux attach; or tmux";
          tk = "tmux kill-session";
          tl = "tmux list-sessions";

          ts = "tailscale";
          tsd = "tailscaled";

          tree = "eza --tree";

          rsf = "rebuild-switch-flake";

          # "," = "git";
          ",a" = "git add";
          ",ap" = "git add --patch";
          ",ad" = "git add .";
          ",r" = "git restore";
          ",rs" = "git restore --staged";
          ",re" = "git reset";
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
          ",l" = "git log";

          "-" = "cd -";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
        };
      };
    }
  ]);
}
