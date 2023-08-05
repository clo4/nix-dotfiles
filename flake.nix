{
  description = "clo4's simple NixOS & nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Language server for Nix, using the flake for latest builds because
    # the nixpkgs release (1.2.0) doesn't pass its checkPhase on Ventura
    nixd.url = "github:nix-community/nixd";

    fish-tide = {
      url = "github:IlanCosman/tide";
      flake = false;
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixos-wsl,
    home-manager,
    darwin,
    flake-utils,
    ...
  }:
  let
    # This defines the home-manager config module for a user called robert.
    # My config structure assumes that this is the only user I'll want to set
    # up, but I'll have to rethink this one day.
    home-manager-robert = path: {
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      home-manager.users.robert = path;
      home-manager.extraSpecialArgs = {
        inherit inputs;
      };
    };
  in
    {
      darwinConfigurations = {
        # Using nix-darwin, configuring the Mac mini itself
        macmini = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            home-manager.darwinModules.default
            (home-manager-robert ./home/macmini)
            ./host/macmini
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };

      nixosConfigurations = {
        # My virtual machine that I run on my Mac
        robert-nixos-utm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            home-manager.nixosModules.default
            (home-manager-robert ./home/utm)
            ./host/utm
          ];
          specialArgs = {
            inherit inputs;
          };
        };

        # My WSL installation
        robert-nixos-wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.default
            nixos-wsl.nixosModules.default
            (home-manager-robert ./home/wsl)
            ./host/wsl
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [inputs.nixd.overlays.default];
      };
    in {
      formatter = pkgs.alejandra;
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          alejandra
          nixd
        ];
      };
    });
}
