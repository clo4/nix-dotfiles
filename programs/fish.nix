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

          # Shell abbreviations
          # Group: shell stuff
          abbr -a cmv "command -v";

          # Group: Nix commands
          abbr -a n "nix";
          abbr -a nxi "nix";
          abbr -a nd "nix develop";
          abbr -a nfuc "nix flake update --commit-lock-file";
          abbr -a rsf "rebuild-switch-flake";

          # Group: Fuzzy finders
          abbr -a f "fzf";

          # Group: tmux
          abbr -a t "tmux";
          abbr -a ta "tmux attach; or tmux";
          abbr -a tk "tmux kill-session";
          abbr -a tl "tmux list-sessions";

          # Group: tailscale (frequently used with sudo)
          abbr -a --position anywhere ts "tailscale";
          abbr -a --position anywhere tsd "tailscaled";

          # Group: File stuff
          abbr -a tree "eza --tree";

          # Group: git
          abbr -a ",a" "git add";
          abbr -a ",ap" "git add --patch";
          abbr -a ",ad" "git add .";
          abbr -a ",r" "git restore";
          abbr -a ",rs" "git restore --staged";
          abbr -a ",re" "git reset";
          abbr -a ",c" "git commit";
          abbr -a ",ca" "git commit --amend";
          abbr -a ",d" "git diff";
          abbr -a ",m" "git merge";
          abbr -a ",s" "git status";
          abbr -a ",p" "git push";
          abbr -a ",pf" "git push --force";
          abbr -a ",pu" "git pull";
          abbr -a ",f" "git fetch";
          abbr -a ",fu" "git fetch upstream";
          abbr -a ",sw" "git switch";
          abbr -a ",sc" "git switch -c";
          abbr -a ",b" "git branch";
          abbr -a ",l" "git log";

          # Group: directory traversal
          abbr -a "-" "cd -";
          abbr -a ".." "cd ..";
          abbr -a "..." "cd ../..";
          abbr -a "...." "cd ../../..";
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

          fish_user_abbreviations = ''
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
            # For this command to be valid, we must be in a git repository
            # that doesn't have a flake.nix in it already
            if test -e flake.nix -o ! -e .git
              echo "flake already exists or not in a git repository, bailing"
              return 1
            end
            nix flake init -t my#simple-shell
            nix flake lock
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
                and test (count $argv) = 1 -a $argv[1] = develop
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
            set_color purple
            echo -n "~~> "
            echo -- "$argv" | fish_indent --ansi
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
      };
    }
  ]);
}
