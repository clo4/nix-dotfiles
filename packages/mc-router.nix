{ pname, pkgs }:
pkgs.buildGoModule {
  inherit pname;
  version = "1.25.1";

  src = pkgs.fetchFromGitHub {
    owner = "itzg";
    repo = pname;
    rev = "7e6c1460da0fa05aa401b04f27d24b96c2dec87c"; # as of 2025-02-27
    hash = "sha256-36WzIVbCTpistRGiye2W4awyUrDqwcww5sSjvTiH74s=";
  };

  vendorHash = "sha256-4hcSgTwbX1Jl3Lx8ZJfJuL/XcYp5FkbEhhGGX58cc9A=";

  meta = {
    description = "Routes Minecraft client connections to backend servers based upon the requested server address";
    homepage = "github.com/itzg/mc-router";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}
