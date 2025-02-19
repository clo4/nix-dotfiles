{
  pkgs,
  inputs,
  perSystem,
}:
pkgs.mkShellNoCC {
  packages = [
    perSystem.agenix.default
    # Allows me to run `run` which executes a fish function
    perSystem.self.runfish
    pkgs.nixos-rebuild
    pkgs.nixos-anywhere
    pkgs.age
    pkgs.lima
  ];
}
