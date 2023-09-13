{
  description = "developer environment definition for `nix develop`";

  #
  # This file needs to be tracked by git, but probably shouldn't be committed!
  # Use your fish function:
  #
  #   git-add-no-track flake.nix flake.lock
  #
  # You can also create do all of this automatically by running this command:
  #
  #   add-simple-shell
  #

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        dependencies = with pkgs; [
          # Your dependencies here
        ];
      };
    });
}
