{ pname, pkgs }:
pkgs.buildGoModule {
  inherit pname;
  version = "1.0.0";

  src = ./.;

  vendorHash = null;
}
