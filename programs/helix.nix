{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programs.helix;

  myTheme = "gruvbox_clo4";
in {
  options.my.programs.helix.enable = mkEnableOption "my helix configuration";

  config = mkIf cfg.enable {
    # Sets EDITOR in the environment, once I'm back to home-manager master
    # I can switch to using the Helix module's porcelain over this -
    # programs.helix.defaultEditor = true;
    home.sessionVariables = {EDITOR = "hx";};

    programs.helix = {
      enable = true;

      settings = {
        theme = myTheme;

        editor = {
          # Override because every terminal I use supports true color, but
          # sometimes helix fails to detect it over ssh, tmux, etc.
          true-color = true;
          color-modes = true;
          line-number = "relative";
          idle-timeout = 0;
          completion-trigger-len = 1;
          bufferline = "multiple";
        };

        editor.statusline = {
          right = [
            "diagnostics"
            "selections"
            "position"
            "position-percentage"
            "file-encoding"
          ];
        };

        editor.cursor-shape = {
          insert = "bar";
          select = "underline";
          normal = "block";
        };

        editor.indent-guides = {
          render = true;
          character = "▏";
          skip-levels = 1;
        };

        editor.whitespace = {
          render.newline = "all";
          characters.newline = "↵";
        };

        editor.lsp = {
          display-messages = false;
        };

        keys.normal = {
          x = "extend_line";
          G = "goto_last_line";

          # Easier movement, don't need to enter another minor mode, encourages
          # more split usage. Arrow keys are discouraged by Vim people but only
          # because they use normal keyboards where the arrows take time to get
          # to. On my current layout, the arrows are basically home-row on my
          # right hand, so there's no speed penalty to using them.
          left = "jump_view_left";
          right = "jump_view_right";
          up = "jump_view_up";
          down = "jump_view_down";

          # Instead of moving focus, move around the buffer history
          C-right = "goto_next_buffer";
          C-left = "goto_previous_buffer";
        };

        keys.normal.space.w = {
          V = ["vsplit_new" "file_picker"];
          S = ["hsplit_new" "file_picker"];
        };

        # Minor mode, perform operations on selection.
        # When custom typable commands land, replace these with typables.
        keys.normal.V = {
          s = ":pipe sort";
          S = ":pipe sort -u";
        };

        keys.select = {
          x = "extend_line";
          # When I collapse a selection in select mode, the next thing I do
          # is *always* enter normal mode.
          ";" = ["collapse_selection" "normal_mode"];
        };

        # This is a pretty standard shortcut in most editors
        keys.insert = {
          C-space = "completion";
        };
      };

      themes.${myTheme} = {
        inherits = "gruvbox";
        comment = {fg = "gray1";};
      };

      languages.language-server = with pkgs;
      with pkgs.nodePackages; {
        typescript-language-server = {
          command = "${typescript-language-server}/bin/typescript-language-server";
          args = ["--stdio" "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"];
        };

        denols = {
          command = "${deno}/bin/deno";
          args = ["lsp"];
          config = {
            enable = true;
            unstable = true;
            lint = true;
          };
        };

        svelteserver.command = "${svelte-language-server}/bin/svelteserver";

        tailwindcss = {
          command = "${nodePackages_latest."@tailwindcss/language-server"}/bin-tailwindcss-language-server";
          language-id = "tailwindcss";
          args = ["--stdio"];
          config = {};
        };

        # nil.command = "${nil}/bin/nil";
        nixd.command = "${nixd}/bin/nixd";

        rust-analyzer.command = "${rust-analyzer-unwrapped}/bin/rust-analyzer";
      };

      languages.language = [
        {
          name = "nix";
          language-servers = ["nixd"];
        }
      ];
    };
  };
}
