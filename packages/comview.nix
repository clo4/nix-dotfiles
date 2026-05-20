{ pname, pkgs, ... }:
pkgs.buildGoModule {
  inherit pname;
  version = "0-unstable-2026-05-19";
  src = pkgs.fetchFromGitHub {
    owner = "rockorager";
    repo = "comview";
    rev = "7aaedd7ecdb1916be1135e4c321b1ca5e26712dd";
    hash = "sha256-LlZ2zOVvLEvvHp+UmzrpP3nOxOpICWGKlzaGLiY7+rA=";
  };
  vendorHash = "sha256-K3mCrhC97/faCPAsuiexwd663H6xMdEWR7DZiafYWAA=";

  meta = {
    description = "The best diff viewer ever made";
    homepage = "https://github.com/rockorager/comview";
    license = pkgs.lib.licenses.mit;
    mainProgram = "comview";
    maintainers = [ ];
  };
}
