{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib; let
  cfg = config.my.programs.helix;
  language = name: text: text;
  myTheme = "gruvbox_clo4";
in {
  options = {
    my.programs.helix.enable = mkEnableOption "my helix configuration";
  };

  config = mkIf cfg.enable {
    # Might have to refactor this into a module or upstream it if I add more queries!
    xdg.configFile."helix/runtime/queries/nix/injections.scm".text = let
      # Helix will override whatever the builtin injection query is with your own
      # if you don't copy it and append your query to it.
      originalNixInjections = builtins.readFile (inputs.helix + "/runtime/queries/nix/injections.scm");
    in
      language "scheme" ''
        ; This is a simple query that allows you to define a function called "language" and
        ; highlight as whatever its first argument is. `language = name: str: str;`
        ((apply_expression
           function: (apply_expression function: (_) @_func
             argument: (string_expression (string_fragment) @injection.language))
           argument: (indented_string_expression (string_fragment) @injection.content))
         (#eq? @_func "language")
         (#set! injection.language))

        ${originalNixInjections}
      '';

    programs.helix = {
      enable = true;
      defaultEditor = true;
      # nu syntax has been updated a fair bit since the last update to the default language file
      package = inputs.helix.packages.${pkgs.stdenv.system}.default.override {
        grammarOverlays = [
          (final: prev: {
            nu = prev.nu.overrideAttrs {
              rev = "2d0dd587dbfc3363d2af4e4141833e718647a67e";
            };
          })
        ];
      };

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
          G = "goto_last_line";

          # This goes against the Helix way of selection->action but it's a
          # common enough thing to warrant making it its own keybind.
          D = ["goto_first_nonwhitespace" "extend_to_line_end" "change_selection"];

          # Mode switching always happens at the end of the list of commands, so
          # the order that these are in doesn't matter because collapsing the selection
          # will always happen first.
          a = ["append_mode" "collapse_selection"];
          i = ["insert_mode" "collapse_selection"];

          # Mnemonic: control hints
          C-h = ":toggle-option lsp.display-inlay-hints";

          # By default, Helix tries to leave the cursor where it was when scrolling
          C-d = ["half_page_down" "goto_window_center"];
          C-u = ["half_page_up" "goto_window_center"];

          # Searching for a selection probably shouldn't have whitespace included.
          # Makes sense to keep the default keybind in select mode though?
          "*" = ["trim_selections" "search_selection"];
        };

        keys.normal.Z = let
          repeat = count: thing:
            if count < 2
            then [thing]
            else [thing] ++ repeat (count - 1) thing;
        in {
          C-d = ["half_page_down" "goto_window_center"];
          C-u = ["half_page_up" "goto_window_center"];

          d = "scroll_down";
          u = "scroll_up";
          e = "scroll_down";
          y = "scroll_up";

          # upper case should move more than one line but less than a half page
          J = repeat 5 "scroll_down";
          K = repeat 5 "scroll_up";
          D = repeat 5 "scroll_down";
          U = repeat 5 "scroll_up";
          E = repeat 5 "scroll_down";
          Y = repeat 5 "scroll_up";
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
          # Mode switching always happens at the end of the list of commands, so
          # the order that these are in doesn't matter because collapsing the selection
          # will always happen first.
          a = ["append_mode" "collapse_selection"];
          i = ["insert_mode" "collapse_selection"];

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

      languages.language-server = {
        deno = {
          command = "deno";
          args = ["lsp"];
          config = {
            enable = true;
            unstable = true;
            lint = true;
          };
        };

        svelteserver.command = "svelteserver";

        tailwindcss = {
          command = "tailwindcss-language-server";
          language-id = "tailwindcss";
          args = ["--stdio"];
          config = {};
        };

        nil.command = "nil";
        nixd.command = "nixd";

        rust-analyzer.command = "rust-analyzer";

        ltex-ls.command = "ltex-ls";
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
            command = "deno";
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
