{ pkgs }:
pkgs.buildNpmPackage {
  pname = "rollbar-mcp-server";
  version = "0.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "rollbar";
    repo = "rollbar-mcp-server";
    rev = "v0.4.0";
    hash = "sha256-n3Tv4HpkhTnSYUFudq0Q1NJ73MFOIVTs+sOL/MjCP5U=";
  };

  npmDepsHash = "sha256-84NQFg7HgJ8Kiu8zx7C3RrfyUEYpQRNP42KTxaIO6GY=";

  buildPhase = ''
    runHook preBuild
    npx tsc
    runHook postBuild
  '';

  meta = {
    description = "Model Context Protocol server for Rollbar";
    homepage = "https://github.com/rollbar/rollbar-mcp-server";
    license = pkgs.lib.licenses.mit;
    maintainers = [ ];
  };
}
