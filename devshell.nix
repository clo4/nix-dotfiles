{
  pkgs,
  inputs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    perSystem.agenix.default
    # In my normal shell, run is a function. In any other shell,
    # or on a system without my configuration, it will instead
    # be the "packaged" version of that function.
    perSystem.self.run
    pkgs.nixos-rebuild
    pkgs.nixos-anywhere
    pkgs.age
    pkgs.lima
    pkgs.deno
    # All this stuff is for developing the ddns client
    pkgs.go
    pkgs.gopls
    pkgs.go-tools
    pkgs.gotools
    pkgs.golangci-lint
    pkgs.clang
  ];
  buildInputs =
    [ ]
    ++ pkgs.lib.optional pkgs.stdenv.isDarwin [
      pkgs.clang
      pkgs.darwin.cctools # I've been burned in the past by not having this
      pkgs.darwin.apple_sdk.frameworks.CoreFoundation
    ];
}
