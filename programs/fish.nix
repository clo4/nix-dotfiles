
{ pkgs, lib, config, inputs, ... }:

with lib;

let
  cfg = config.my.programs.fish;
in {
  options.my.programs.fish = {
    enable = mkEnableOption "my fish configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs.fishPlugins; [
      # Tide can be configured to be quite minimal.
      # tide

      # Mnemonic keybindings to use fzf.
      # fzf-fish
    ];

    programs.fish = {
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

        # This function is automatically executed at startup to define the bindings that
        # Fish will use.
        # fish_hybrid_key_bindings enables Vi keybindings but enables emacs keybindings in all modes,
        # allowing arrow keys, C-f/b, etc. to still work.
        # It also includes M-e which will open the commandline in your editor, granting the full power
        # of Helix for writing commands if necessary.
        fish_user_key_bindings = ''
          # fish_hybrid_key_bindings

          # for mode in normal insert select
              # bind -M $mode \cz 'fg 2>/dev/null; commandline -f repaint'
          # end

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
          st newcwd $argv[1]
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
              echo 'Requires 2 arguments.  Usage: suff files... suffix' >&2
              return 1
          end

          set suffix $argv[-1]
          set paths $argv[..-2]

          for path in $paths
              mv $path $path$suffix
          end
        '';
      };

      shellAbbrs = {
        # Did you know `which` isn't a builtin?
        cmv = "command -v";

        ndev = "nix develop --command fish";

        f = "fzf";

        t = "tmux";
        ta = "tmux attach; or tmux";
        tk = "tmux kill-session";
        tl = "tmux list-sessions";

        # Using , instead of 'g' for git because g is annoying to reach
        "," = "git";
        ",a" = "git add";
        ",ad" = "git add ."; # git-add-dot
        ",c" = "git commit";
        ",cp" = "git commit; and git push"; # git-commit-push
        ",cap" = "git commit -a; and git push"; # The YOLO option, git-commit-all-push
        ",d" = "git diff";
        ",m" = "git merge";
        ",s" = "git status";
        ",p" = "git push";
        ",sw" = "git switch";
        ",sc" = "git switch -c";

        "-" = "cd -";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
      };
    };
  };
}
