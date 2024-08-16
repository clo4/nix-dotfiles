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

    ghostty.url = "github:clo4/ghostty-hm-module";

    # This is only here to declaratively add it to the registry
    mkshell.url = "github:clo4/mkshell";

    # Case conversion utility that I'm using for some Helix keybinds
    ccase = {
      url = "github:rutrum/ccase";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fish-tide = {
      url = "github:IlanCosman/tide/v6.1.1";
      flake = false;
    };

    # I use tealdeer as a quick reference for some commands, but I want the
    # tldr page cache to be managed by my Nix setup instead.
    tldr-pages = {
      url = "github:tldr-pages/tldr";
      flake = false;
    };

    # TODO: I think I can remove this now
    skyrocket-spoon = {
      url = "github:clo4/SkyRocket.spoon";
      flake = false;
    };

    # nix-homebrew allows you to configure homebrew declaratively, so the taps
    # can be managed by nix as well. Keeps all versions predictable!
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixos-wsl,
    home-manager,
    darwin,
    flake-utils,
    ghostty,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    ...
  }: let
    # This defines the home-manager config module for a user called robert.
    # My config structure assumes that this is the only user I'll want to set
    # up, but I'll have to rethink this one day.
    home-manager-robert = path: {
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        users.robert = path;
        sharedModules = [
          ghostty.homeModules.default
        ];
        extraSpecialArgs = {
          inherit inputs;
        };
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
            (home-manager-robert ./systems/macmini/home.nix)
            ./systems/macmini/host.nix
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
            (home-manager-robert ./systems/utm/home.nix)
            ./systems/utm/host.nix
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
            (home-manager-robert ./systems/wsl/home.nix)
            ./systems/wsl/host.nix
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };

      templates = {
        untracked-flake = {
          path = ./templates/untracked-flake;
          description = "Flake to be used with my `mkflake` shell function";
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.alejandra;
      devShell = pkgs.mkShell {
        packages = with pkgs; [
          nil
          alejandra
        ];
      };
    });
}
