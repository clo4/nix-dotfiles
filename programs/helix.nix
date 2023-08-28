{
  pkgs,
  config,
  lib,
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
          display-messages = true;
          display-inlay-hints = true;
        };

        keys.normal = {
          # Extends based on which side of the selection the head is on,
          # eg. if the head is on the left, the selection will extend up.
          x = "extend_line";

          G = "goto_last_line";

          # This goes against the Helix way of selection->action but it's a
          # common-enough thing to warrant making it its own keybind.
          D = ["goto_first_nonwhitespace" "extend_to_line_end" "change_selection"];

          a = ["append_mode" "collapse_selection"];
          i = ["insert_mode" "collapse_selection"];

          # Mnemonic: control hints
          C-h = ":toggle-option lsp.display-inlay-hints";

          C-d = ["half_page_down" "goto_window_center"];
          C-u = ["half_page_up" "goto_window_center"];

          # Easier movement, don't need to enter another minor mode, encourages
          # more split usage. Arrow keys are discouraged by Vim people but only
          # because they use normal keyboards where the arrows take time to get
          # to. On my current layout, the arrows are basically home-row on my
          # right hand, so there's no speed penalty to using them.
          left = "jump_view_left";
          right = "jump_view_right";
          up = "jump_view_up";
          down = "jump_view_down";
        };

        keys.normal.Z = {
          C-d = ["half_page_down" "goto_window_center"];
          C-u = ["half_page_up" "goto_window_center"];

          d = "scroll_down";
          u = "scroll_up";
          e = "scroll_down";
          y = "scroll_up";
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

          C-h = ":toggle-option lsp.display-inlay-hints";

          C-d = ["half_page_down" "goto_window_center"];
          C-u = ["half_page_up" "goto_window_center"];

          # When I collapse a selection in select mode, the next thing I do
          # is *always* enter normal mode.
          ";" = ["collapse_selection" "normal_mode"];
        };

        keys.insert = {
          C-h = ":toggle-option lsp.display-inlay-hints";

          # This is a pretty standard shortcut in most editors
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

        deno = {
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

        nil.command = "${nil}/bin/nil";
        nixd.command = "${nixd}/bin/nixd";

        rust-analyzer.command = "${rust-analyzer-unwrapped}/bin/rust-analyzer";

        ltex-ls.command = "${ltex-ls}/bin/ltex-ls";
      };

      languages.language = [
        {
          name = "nix";
          language-servers = ["nil"];
          auto-format = true;
          formatter = {
            command = "${pkgs.alejandra}/bin/alejandra";
            args = ["-"];
          };
        }
        {
          name = "fish";
          auto-format = true;
          formatter.command = "${pkgs.fish}/bin/fish_indent";
        }
        {
          name = "markdown";
          language-servers = ["ltex-ls"];
          auto-format = false;
          formatter = {
            command = "${pkgs.deno}/bin/deno";
            args = ["--ext" "md" "-"];
          };
        }
        {
          name = "git-commit";
          language-servers = ["ltex-ls"];
        }
      ];
    };
  };
}
