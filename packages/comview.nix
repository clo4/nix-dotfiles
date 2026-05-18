{ pname, pkgs, ... }:
pkgs.buildGoModule {
  inherit pname;
  version = "0-unstable-2026-05-18";
  src = pkgs.fetchFromGitHub {
    owner = "rockorager";
    repo = "comview";
    rev = "e056eda31158a6108525a0e8c66c40ca5caca8a8";
    hash = "sha256-V93kq3MCWBqrpUrxDCoSNmXtZiv3+1LYQnsozmP/9q8=";
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
