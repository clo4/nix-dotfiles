{ pkgs }:
pkgs.writeScriptBin "run" ''
  #!${pkgs.fish}/bin/fish
  ${builtins.readFile ./run.fish}
''
