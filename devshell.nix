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
  ];
}
