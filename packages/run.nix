{ pkgs, flake }:
pkgs.stdenv.mkDerivation {
  name = "run";

  src = flake;

  buildInputs = [ pkgs.fish ];

  installPhase = ''
    mkdir -p $out/bin
    echo "#!${pkgs.fish}/bin/fish" > $out/bin/run
    echo "" >> $out/bin/run
    cat config/fish/functions/run.fish >> $out/bin/run
    echo "" >> $out/bin/run
    echo "run \$argv" >> $out/bin/run
    chmod +x $out/bin/run

    mkdir -p $out/share/fish/vendor_completions.d
    cp config/fish/completions/run.fish $out/share/fish/vendor_completions.d/

    mkdir -p $out/share/fish/vendor_functions.d
    cp config/fish/functions/run.fish $out/share/fish/vendor_functions.d/
  '';
}
