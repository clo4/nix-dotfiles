{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.my.programs.helix;
  language = name: text: text;
  myTheme = "gruvbox_clo4";
in
{
  options = {
    my.programs.helix.enable = mkEnableOption "my helix configuration";
  };

  config = mkIf cfg.enable {
    home.file.".config/helix".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Developer/nix-dotfiles/config/helix";

    # Might have to refactor this into a module or upstream it if I add more queries!
    # xdg.configFile."helix/runtime/queries/nix/injections.scm".text =
    #   let
    #     # Helix will override whatever the builtin injection query is with your own
    #     # if you don't copy it and append your query to it.
    #     originalNixInjections = builtins.readFile (inputs.helix + "/runtime/queries/nix/injections.scm");
    #   in
    #   language "scheme" ''
    #     ; This is a simple query that allows you to define a function called "language" and
    #     ; highlight as whatever its first argument is. `language = name: str: str;`
    #     ((apply_expression
    #        function: (apply_expression function: (_) @_func
    #          argument: (string_expression (string_fragment) @injection.language))
    #        argument: (indented_string_expression (string_fragment) @injection.content))
    #      (#eq? @_func "language")
    #      (#set! injection.language))

    #     ${originalNixInjections}
    #   '';

    # xdg.configFile."helix/runtime/queries/go/injections.scm".text =
    #   let
    #     originalGoInjections = builtins.readFile (inputs.helix + "/runtime/queries/go/injections.scm");
    #   in
    #   language "scheme" ''
    #     ; Inject SQL as the first argument to the standard library's SQL methods.
    #     ; These methods take `sqlString` as the first argument
    #     ((call_expression
    #       function: (selector_expression
    #         operand: (_)
    #         field: (field_identifier) @_method (#any-of? @_method "Query" "QueryRow" "Exec" "Prepare"))
    #       arguments: (argument_list
    #         .
    #         [(interpreted_string_literal) (raw_string_literal)] @injection.content))
    #       (#set! injection.language "sql"))

    #     ; Inject SQL as the second argument to all the different SQL query methods.
    #     ; This supports the style that PGX uses the same names as the standard library
    #     ; but take a context as the first argument.
    #     ((call_expression
    #       function: (selector_expression
    #         operand: (_)
    #         field: (field_identifier) @_method (#any-of? @_method "Query" "QueryRow" "QueryContext" "QueryRowContext" "Exec" "ExecContext" "Prepare" "PrepareContext"))
    #       arguments: (argument_list
    #         . (_)
    #         . [(interpreted_string_literal) (raw_string_literal)] @injection.content))
    #       (#set! injection.language "sql"))

    #     ${originalGoInjections}
    #   '';

    home.packages = [ inputs.helix.packages.${pkgs.stdenv.system}.default ];
    home.sessionVariables = {
      EDITOR = "hx";
    };
  };
}
