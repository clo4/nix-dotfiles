{ pkgs, flake }:
pkgs.stdenv.mkDerivation {
  name = "run";

  src = flake;

  buildInputs = [ pkgs.fish ];

  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/run <<'NIXPACKAGESCRIPT'
    #!${pkgs.fish}/bin/fish
    $(cat config/fish/functions/run.fish)

    run $argv
    NIXPACKAGESCRIPT

    chmod +x $out/bin/run

    mkdir -p $out/share/fish/vendor_completions.d
    cp config/fish/completions/run.fish $out/share/fish/vendor_completions.d/

    mkdir -p $out/share/fish/vendor_functions.d
    cp config/fish/functions/run.fish $out/share/fish/vendor_functions.d/
  '';
}
