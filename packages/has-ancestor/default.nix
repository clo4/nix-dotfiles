{ pkgs }:
pkgs.stdenv.mkDerivation {
  pname = "has-ancestor";
  version = "0.1.0";

  src = ./.;

  buildPhase = ''
    $CC -O2 -Wall -Wextra -o has-ancestor main.c
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp has-ancestor $out/bin/
  '';
}
