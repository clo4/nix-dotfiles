{ pkgs }:
# Requires specifying the go version because it uses the 'tool' directive.
# At the time of writing, the version used by buildGoModule is 1.23.5, but the
# latest available is 1.24
pkgs.buildGo124Module rec {
  pname = "mrpack-install";
  # current as of 2025-02-20
  version = "v0.20.0-beta";

  src = pkgs.fetchFromGitHub {
    owner = "nothub";
    repo = "mrpack-install";
    rev = "${version}";
    hash = "sha256-vMueeK9iLr4W7LFJ+FQxATpB4s7QXazFVOmZ4SQ9B+M=";
  };

  vendorHash = "sha256-GA3dbl+Rld6xlW5is3SINEhYIjfm00Sy8B51hgOcfCw=";

  doCheck = false;
}
