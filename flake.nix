{
  description = "clo4's simple NixOS & nix-darwin configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    # ---

    helix = {
      url = "github:helix-editor/helix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixd.url = "github:nix-community/nixd";

    # ---

    # Fish plugins -- ultimately I don't really use a lot of them because
    # for the most part the shell does everything I need it to out of the box.

    # Tide is a minimal (or maximal if you prefer) prompt, but it's really fast.
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
  # Currently this config makes the assumption that I only want to set up
  # one user and that user's username is "robert". This will be hardcoded
  # but when I eventually need to address this I'll need to grep for "robert"
  let
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
