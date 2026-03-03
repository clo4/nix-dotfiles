{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "if-not-in-fish";
  version = "0.1.0";

  src = ./.;

  buildPhase = ''
    $CC -O2 -Wall -Wextra -o if-not-in-fish main.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp if-not-in-fish $out/bin/
  '';
}
