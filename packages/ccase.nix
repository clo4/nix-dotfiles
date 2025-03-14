{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "0.4.1";
  src = pkgs.fetchFromGitHub {
    owner = "rutrum";
    repo = pname;
    rev = "7ca56557d0cc69641e0d0c5ae9370c48f4cce09d";
    hash = "sha256-TQJkvANms/5Mzh1J4qsEYOrlML17dVv7MYEoN4Z/gm0=";
  };
  cargoHash = "sha256-RLjwLr1IF1T3QR5t8i2dGEWs72YY49Ib1l8QlaFkcqg=";
  useFetchCargoVendor = true;

  meta = {
    description = "Command line interface to convert strings into any case";
    homepage = "https://github.com/rutrum/ccase";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}
