{ pname, pkgs, ... }:
pkgs.buildGoModule {
  inherit pname;
  version = "0-unstable-2026-06-02";
  src = pkgs.fetchFromGitHub {
    owner = "rockorager";
    repo = "comview";
    rev = "08a35f43a467783015ff12557ac02c0e30004e2f";
    hash = "sha256-4zu6PKXRcf1j0Bavql/i/apyJt4ArhnMgW2jqAoBazs=";
  };
  vendorHash = "sha256-f7Q4+Bd22xnxkOWjgv4TzPmgZTNHhYvMtoVyl9anGzc=";

  meta = {
    description = "The best diff viewer ever made";
    homepage = "https://github.com/rockorager/comview";
    license = pkgs.lib.licenses.mit;
    mainProgram = "comview";
    maintainers = [ ];
  };
}
